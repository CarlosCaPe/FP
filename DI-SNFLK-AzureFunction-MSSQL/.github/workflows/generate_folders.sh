# set main folder paths
topdir=${GITHUB_WORKSPACE}
tmpldir=$topdir/function_template
confdir=$topdir/config_files

# loop over directory files
for sitedir in "$confdir"/*/; do
    for appdir in "$sitedir"/*/; do
        for dbdir in "$appdir"/*/; do
            for schdir in "$dbdir"/*/; do
                for tblconf in "$schdir"/*; do
                    # get site, app, database and file name
                    site=$(basename "$sitedir")
                    app=$(basename "$appdir")
                    db=$(basename "$dbdir")
                    sch=$(basename "$schdir")
                    tbl=$(basename "$tblconf" .json)
                    # get function folder path
                    funcdir="$topdir/${site^^}-${app^^}-${db^^}-${sch^^}-${tbl,,}"
                    # create function folder
                    mkdir "$funcdir"
                    # copy files
                    cp $tmpldir/__init__.py $funcdir/__init__.py
                    cp $tblconf $funcdir/function.json
                done
            done
        done
    done
done

# delete unused folders
rm -r $tmpldir
rm -r $confdir
