const fs = require('fs');
const path = require('path');

const env = process.env.ENVIRONMENT;
const configsPath = path.join(process.env.GITHUB_WORKSPACE, process.env.FILES_FOLDER);
const templatePath = path.join(process.env.GITHUB_WORKSPACE, process.env.TEMPLATE_FOLDER, '__init__.py');
let settings = process.env.SETTINGS;

if (settings) {
    console.log('Settings already defined, will append new settings')
    settings = JSON.parse(settings)
}
else {
    console.log('Settings not defined, will load inital settings')
    const settingsPath = path.join(process.env.GITHUB_WORKSPACE, '.github/workflows/settings.json');
    const data = fs.readFileSync(settingsPath, 'utf-8');
    settings = JSON.parse(data)[env];
}
    
function readDirectory(parentPath) {
    try {
        const children = fs.readdirSync(parentPath);

        for (const child of children) {
            const childPath = path.join(parentPath, child);
            const stats = fs.statSync(childPath);

            if (stats.isDirectory()) {
                readDirectory(childPath);
            } else {
                processFile(childPath);
            }
        }
    } catch (error) {
        console.error(`Error reading directory ${parentPath}: ${error.message}`);
    }
}

function processFile(filePath) {
    try {
        const data = fs.readFileSync(filePath, 'utf-8');
        const jsonData = JSON.parse(data);
        if (jsonData.hasOwnProperty('bindings')) {
            let [app, database, schema, fileName] = filePath.split(path.sep).slice(-4).map(str => str.toUpperCase());
            fileName = fileName.split('.')[0].toUpperCase()
            const folderName = [app, database, schema, fileName].join('_')
            fs.mkdirSync(path.join(process.env.GITHUB_WORKSPACE, folderName));
            fs.copyFileSync(filePath, path.join(process.env.GITHUB_WORKSPACE, folderName, 'function.json'))
            fs.copyFileSync(templatePath, path.join(process.env.GITHUB_WORKSPACE, folderName, '__init__.py'))
            console.log(`Function Folder Created: ${folderName}`);
        }
        else if (jsonData.hasOwnProperty(env)) {
            const database = filePath.split(path.sep).slice(-1)[0].toUpperCase()
            settings = settings.concat(jsonData[env]);
            console.log(`Setting Created: ${database}`);
        }
    }
    catch (error) {
        console.error(`Error reading file ${filePath}: ${error.message}`);
    }
}

function setStartUpTime() {
    let date = (new Date()).toISOString();
    settings.push({"name": "STARTUP_TIME_UTC", "value": date, "slotSetting": true});
}

setStartUpTime();
readDirectory(configsPath);

module.exports = ({github, context, core}) => {
    core.exportVariable('SETTINGS', settings);
};
