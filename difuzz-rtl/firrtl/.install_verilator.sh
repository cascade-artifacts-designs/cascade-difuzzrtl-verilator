set -e
# Install Verilator (http://www.veripool.org/projects/verilator/wiki/Installing)
if [ ! -f $INSTALL_DIR/bin/verilator ]; then 
  mkdir -p $INSTALL_DIR
  git clone https://github.com/verilator/verilator.git
  unset VERILATOR_ROOT
  cd verilator
  git pull
  git checkout v3.922
  autoconf
  ./configure --prefix=$INSTALL_DIR
  make
  make install
  export VERILATOR_ROOT=$INSTALL_DIR
  # Fix verilator for local install (http://www.lowrisc.org/docs/untether-v0.2/verilator/)
  ln -s $VERILATOR_ROOT/share/verilator/include $VERILATOR_ROOT/include
  ln -s $VERILATOR_ROOT/share/verilator/bin/verilator_includer $VERILATOR_ROOT/bin/verilator_includer
fi