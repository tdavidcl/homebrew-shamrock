class Shamrock < Formula
  desc "Astrophysical hydrodynamics using SYCL"
  homepage "https://github.com/Shamrock-code/Shamrock"
  url "https://github.com/Shamrock-code/Shamrock/releases/download/v2025.10.0/shamrock-2025.10.0.tar"
  sha256 "72683352d862d7b3d39568151a17ea78633bd4976a40eacb77098d3ef0ca3c55"
  license "CECILL-2.1"
  revision 1
  head "https://github.com/Shamrock-code/Shamrock.git", branch: "main"

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
    rm_r(%w[
      external/fmt
      external/nlohmann_json
      external/pybind11
    ])

    args = %W[
      -DSHAMROCK_ENABLE_BACKEND=SYCL
      -DPYTHON_EXECUTABLE=#{python}
      -DCMAKE_INSTALL_PYTHONDIR=#{site_packages(python).join("shamrock")}
      -DSYCL_IMPLEMENTATION=ACPPDirect
      -DCMAKE_CXX_COMPILER=acpp
      -DACPP_PATH=#{Formula["adaptivecpp"].opt_prefix}
      -DSHAMROCK_EXTERNAL_FMTLIB=ON
      -DSHAMROCK_EXTERNAL_JSON=ON
      -DSHAMROCK_EXTERNAL_PYBIND11=ON
    ]

    system "cmake", "-S", ".", "-B", "build", *args, *std_cmake_args
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"
  end

  test do
    (testpath/"test.py").write <<~PY
      import shamrock
      shamrock.change_loglevel(125)
      if not shamrock.sys.is_initialized():
        shamrock.sys.init('0:0')
      # To test that importing nested modules works
      from shamrock.math import *
    PY
    
    # Basic cases
    system bin/"shamrock", "--help"
    system bin/"shamrock", "--smi"
    system "mpirun", "-n", "1", bin/"shamrock", "--smi"

    # Will test that kernels can run too
    system python, "test.py"
    system bin/"shamrock", "--smi", "--sycl-cfg", "0:0", "--rscript", "test.py"
  end
end