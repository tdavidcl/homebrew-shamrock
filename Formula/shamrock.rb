class Shamrock < Formula
  desc "Astrophysical hydrodynamics using SYCL"
  homepage "https://github.com/Shamrock-code/Shamrock"
  url "file:///Users/davidclt/Downloads/Shamrock.tar", using: :nounzip
  sha256 "0ca54e35f88f4b7e14c372933d0cea96b11fa43c0b9248291b823eb5989fa1f2"
  version "2025.05.0"
  license "CECILL-2.1"
  revision 1
  head "https://github.com/Shamrock-code/Shamrock.git", branch: "main"

  no_autobump! because: :requires_manual_review

  depends_on "cmake" => :build
  depends_on "fmt" => :build
  depends_on "nlohmann-json" => :build
  depends_on "pybind11" => :build
  depends_on "adaptivecpp"
  depends_on "boost"
  depends_on "open-mpi"
  depends_on "python@3.14"

  on_macos do
    depends_on "libomp"
  end

  def python
    which("python3.14")
  end

  def site_packages(python)
    prefix/Language::Python.site_packages(python)
  end

  def install
    args = %W[
      -DSHAMROCK_ENABLE_BACKEND=SYCL
      -DPYTHON_EXECUTABLE=#{python}
      -DSYCL_IMPLEMENTATION=ACPPDirect
      -DCMAKE_CXX_COMPILER=acpp
      -DACPP_PATH=#{Formula["adaptivecpp"].opt_prefix}
      -DCMAKE_INSTALL_PYTHONDIR=#{prefix/Language::Python.site_packages(python)}
      -DSHAMROCK_EXTERNAL_FMTLIB=ON
      -DSHAMROCK_EXTERNAL_JSON=ON
      -DSHAMROCK_EXTERNAL_PYBIND11=ON
    ]

    system "ls", "-la"
    system "cmake", "-S", ".", "-B", "build", *args, *std_cmake_args
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"

    py_package = site_packages(python).join("shamrock")

    mkdir_p py_package
    cp_r Dir["build/*.so"], py_package

    (py_package/"__init__.py").write <<~PY
      from .shamrock import *
    PY
  end

  test do
    system bin/"shamrock", "--help"
    system bin/"shamrock", "--smi"
    system "mpirun", "-n", "1", bin/"shamrock", "--smi", "--sycl-cfg", "auto:OpenMP"
    (testpath/"test.py").write <<~PY
      import shamrock
      shamrock.change_loglevel(125)
      shamrock.sys.init('0:0')
      shamrock.sys.close()
    PY
    system python, testpath/"test.py"
  end
end