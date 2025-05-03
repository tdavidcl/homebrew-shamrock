class Shamrock < Formula
  desc "Astrophysical hydrodynamics using SYLC"
  homepage "https://github.com/Shamrock-code/Shamrock"
  url "https://github.com/Shamrock-code/Shamrock/releases/download/v2025.05.0/shamrock-2025.05.0.tar"
  sha256 "59d5652467fd9453a65ae7b48e0c9b7d4162edc8df92e09d08dcc5275407a897"
  license "BSD-2-Clause"

  depends_on "cmake" => :build
  depends_on "adaptivecpp"
  depends_on "fmt"
  depends_on "open-mpi"
  depends_on "python@3.13"

  def python
    which("python3.13")
  end

  def site_packages(python)
    prefix/Language::Python.site_packages(python)
  end

  def install
    adaptivecpp_root = Formula["adaptivecpp"].opt_prefix

    system "cmake", ".", *std_cmake_args,
        "-DSHAMROCK_ENABLE_BACKEND=SYCL",
        "-DPYTHON_EXECUTABLE=#{python}",
        "-DSYCL_IMPLEMENTATION=ACPPDirect",
        "-DCMAKE_CXX_COMPILER=acpp",
        "-DACPP_PATH=#{adaptivecpp_root}",
        "-DCMAKE_BUILD_TYPE=Release",
        "-DBUILD_TEST=Yes",
        "-DUSE_SYSTEM_FMTLIB=Yes"

    system "cmake", "--build", "."
    system "cmake", "--install", "."

    py_package = site_packages(python).join("shamrock")

    mkdir_p py_package
    cp_r Dir["*.so"], py_package

    (py_package/"__init__.py").write <<~EOS
      from .shamrock import *
    EOS
  end

  test do
    system "#{bin}/shamrock", "--help"
    system "#{bin}/shamrock", "--smi"
    system "mpirun", "-n", "1", "#{bin}/shamrock", "--smi", "--sycl-cfg", "auto:OpenMP"
    test_py = "test.py"
    test_py.write <<~EOS
      import shamrock
      shamrock.change_loglevel(125)
      shamrock.sys.init('0:0')
      shamrock.sys.close()
    EOS
    system python.to_s, test_py
  end
end
