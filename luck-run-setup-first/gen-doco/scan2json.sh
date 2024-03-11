#!/bin/bash

if [ -f "$1" ]; then
    echo "文件 $1 存在"
else
    echo "文件 $1 不存在"
    exit 1
fi


targetfile=$(realpath $1)
targetfile_s_h=$(echo `cat ${targetfile} | grep '^#include <.*>$'  | sed 's/^#include <\(.*\)>$/\1/'`|sed 's/^\|$\| /XX/g')
targetfile_c_h=$(echo `cat ${targetfile} | grep '^#include ".*"$'  | sed 's/^#include "\(.*\)"$/\1/'`|sed 's/^\|$\| /XX/g')


SCRIPT_REL_PATH=$(dirname "$0")
export SCRIPT_ABS_PATH=$(realpath ${SCRIPT_REL_PATH})
PROJECTPATH=$(realpath ${SCRIPT_ABS_PATH}/../../)

targetfile_dir=$(dirname $targetfile)
targetfile_dir_rel=$(realpath --relative-to="$PROJECTPATH" "$targetfile_dir")


colors=("#000" "#00f" "#f00" "#0ff" "#ff0" "#f0f" "#0aa" "#a0a" "#aa0" "#555")
backgrounds=("#765" "#f0f" "#0f0" "#00f" "#0ff" "#ff0" "#a00" "#0a0" "#00a" "#ccc")
counter=0


generate_json_static_syms(){
  sdefs=$(echo `cat $targetfile | grep '^#define '|awk '{print $2}'|sed 's/(.*//g'`|tr ' ' '|')
  ssyms=$(echo `cat $targetfile |sed -n '/^static.*(/p; /static[^(]*$/ {N; /(/p;}'|grep -o "\w*("|sort -r|uniq|grep -o "\w*"`|tr ' ' '|')
  sresult=
  if [ -n "$ssyms" ] && [ -n "$sdefs" ]; then
    sresult="${ssyms}|${sdefs}"
  elif [ -n "$ssyms" ]; then
    sresult="$ssyms"
  elif [ -n "$sdefs" ]; then
    sresult="$sdefs"
  fi
  cat <<EOF
        "(${sresult})": {
            "regexFlags": "g",
            "filterLanguageRegex": "c",
            "filterFileRegex": "$targetfile",
            "decorations": [
                {
                    "before": {
                        "textDecoration": "\`;color: #ffbd09;font-size: 1em;border-radius: 1em;padding: 0 0.2em;\`",
                        "contentText": "(s)",
                        "margin": "0 0.5em;",
                        "color": "#fff",
                        "backgroundColor": "#953"
                    }
                }
            ]
        },
EOF
}

generate_json_ext_syms(){


  for i in `find -name "*.h"`; do
    ii=$(echo ${i} | sed 's/^\.\///')
    if [[ ${1} == *X${ii}X* ]]; then
      echo ""
      color=${colors[$counter]}
      background=${backgrounds[$counter]}
      ((counter = (counter + 1) % ${#colors[@]}))
    else
      continue
    fi

    defs=$(echo `cat $i | grep '^#define '|awk '{print $2}'|sed 's/(.*//g'`|tr ' ' '|')
    # syms=$(`cat ${i} |sed -n '/^static.*(/p; /static[^(]*$/ {N; /(/p;}'|grep -o "\w*("|sort -r|uniq|grep -o "\w*"`|tr ' ' '|')
    syms=$(echo `grep -v '^[[:space:]]\|typedef' $i|grep '.*(.*[,;]$'|awk -F '(' '{print $1}'|awk '{print $NF}' |sed 's/^[^a-zA-Z0-9_]*//g'`|sed 's/^/(?<=\[^a-zA-Z0-9_\])/g' |sed 's/$/(?=\[^a-zA-Z0-9_\])/g' | sed 's/ /(?=\[^a-zA-Z0-9_\])|(?<=\[^a-zA-Z0-9_\])/g')
    ssyms=$(echo `cat $i |sed -n '/^static.*(/p; /static[^(]*$/ {N; /(/p;}'|grep -o "\w*("|sort -r|uniq|grep -o "\w*"`|tr ' ' '|')

    result=

    if [ -n "$syms" ] && [ -n "$defs" ]; then
      result="${syms}|${defs}"
    elif [ -n "$syms" ]; then
      result="$syms"
    elif [ -n "$defs" ]; then
      result="$defs"
    fi
    cat <<EOF
        "(${result})": {
            "regexFlags": "g",
            "filterLanguageRegex": "c",
            "filterFileRegex": "${targetfile_dir_rel}.*.c",
            "decorations": [
                {
                    "before": {
                        "textDecoration": "\`;color: #ffbd09;font-size: 1em;border-radius: 1em;padding: 0 0.2em;\`",
                        "contentText": "${ii} ",
                        "margin": "0 0.5em;",
                        "color": "${color}",
                        "backgroundColor": "${background}"
                    }
                }
            ]
        },
EOF

  done

}


echo "// ############################ highlight start ######################################################"

generate_json_static_syms

cd ${PROJECTPATH}/include &>/dev/null
generate_json_ext_syms ${targetfile_s_h}
cd - &>/dev/null

cd $(dirname $targetfile) &>/dev/null
generate_json_ext_syms ${targetfile_c_h}
cd - &>/dev/null


echo "// ############################ highlight end ######################################################"