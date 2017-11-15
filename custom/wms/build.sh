__dir__=$(cd $(dirname ${BASH_SOURCE[0]}); pwd )
__rootdir__=$(cd ${__dir__}/../.. ; pwd)
__libdir__=$(cd $__rootdir__/commands/lib; pwd )
__custom__=wms
__customdir__=$(cd $__rootdir__/custom/$__custom__; pwd )
__config__=$__rootdir__/config.ini
__debug__=
__build__=Yes
__install__=Yes

function check(){
    
    if [ $? -ne 0 ]; then
	   echo "[Fail] $1"
	   exit 1	
	else
	   echo "[OK] $1"
	   return 0
	fi
}



function _arguments(){

  while [ ! -z $1 ] ; do
    opt=$1
    case $opt in
      --debug)
      __debug__=Yes
      shift
      ;;
      --release)
      __debug__=Yes
      shift
      ;;
      
      --disable-install)
      __install__=
      shift
      ;;
      
      --disable-build)
      __build__=
      shift 
      ;;
      *) 
    
      break
      ;;
    esac
  done
  
  
  __cbc__=win64
  [ "x$(uname)" == "xLinux" ] &&  __cbc__= lin64
  [ ! -z $__debug__ ] && __cbc__=${__cbc__}d
  __cbc__=${__cbc__}.cbc
  
}







function _install(){
  cbc=config/$__cbc__
  cerbero=$( $__libdir__/cerbero -c $cbc -i $__config__)
  # clear previous build
  
  for key in prefix build_tools_prefix logs sources
  do
      d = $($cerbero.get_config $key)
	  [ -d $d ] && rm -rf $d
  done

  #prefix=$($cerbero.get_config prefix)
  #[ -d $prefix ] && rm -rf $prefix
  #
  #build_tools_prefix=$($cerbero.get_config build_tools_prefix)
  #[ -d $build_tools_prefix ] && rm -rf $build_tools_prefix

  pkgname=$($cerbero.build_tools_pkg_name)
  repo=$($cerbero.release_repo build_tools)


  $cerbero.run cpm-install  $pkgname --repo $repo --build-tools
  check "install $pkgname at $repo"

  for name in  base gstreamer ribbon
  do
     repo=$($cerbero.release_repo $name)
     $cerbero.run cpm-install  --repo $repo --type build
     check "install $name SDK at $repo"   
  done
  echo "SDK install completed!"
}






function _build(){

  cbc=$__dir__/config/$__cbc__
  cerbero=$( $__libdir__/cerbero -c $cbc -i $__config__ -u $__custom__)
  rdir=$($cerbero.release_dir )/$($cerbero.release_tag $__custom__)


  [ -d $rdir ] && rm -rf $rdir
  mkdir -p $rdir/tarball
  
  cache=$($cerbero.get_config home_dir)/$($cerbero.get_config cache_file )
  
  [ -f $cache ] && rm -rf $cache
  
  
  $cerbero.run package wms --tarball -o $rdir/tarball
  check "Build $__custom__"

  $cerbero.run cpm-pack wms --type sdk --output-dir $rdir
  check "Pack $__custom__"

}



_arguments $@
[ ! -z $__install__ ] && _install
[ ! -z $__build__ ] && _build
