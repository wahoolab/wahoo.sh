

if [[ ! -f ./bin/.wahoo-setup.sh ]]; then
   echo "Error: setup must be run from the \${WAHOO_HOME}/bin directory."
   exit 1
fi

cd bin || exit 1
./.wahoo-setup.sh

