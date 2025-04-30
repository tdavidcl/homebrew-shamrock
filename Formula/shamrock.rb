class Shamrock < Formula
  desc "Astrophysical hydrodynamics using SYLC"
  homepage "https://github.com/Shamrock-code/Shamrock"
  url "https://github.com/Shamrock-code/Shamrock/releases/download/v2025.03.1/shamrock-2025.03.1.tar"
  sha256 "df5b4af63944f5e97332baaafe6b0c8db11300c1d2f9a7676593f80c8ee92d7f"
  license "BSD-2-Clause"

  depends_on "cmake" => :build
  depends_on "adaptivecpp"
  depends_on "fmt"
  depends_on "open-mpi"
  depends_on "python"

  def install
    libomp_root = Formula["libomp"].opt_prefix
    adaptivecpp_root = Formula["adaptivecpp"].opt_prefix

    puts "libomp root: #{libomp_root}"

    system "cmake", ".", *std_cmake_args,
        "-DSHAMROCK_ENABLE_BACKEND=SYCL",
        "-DSYCL_IMPLEMENTATION=ACPPDirect",
        "-DCMAKE_CXX_COMPILER=acpp",
        "-DACPP_PATH=#{adaptivecpp_root}",
        "-DCMAKE_BUILD_TYPE=Release",
        "-DBUILD_TEST=Yes",
        "-DUSE_SYSTEM_FMTLIB=Yes"

    system "make", "install"
  end

  test do
    system "#{bin}/shamrock", "--help"
    system "#{bin}/shamrock", "--smi"
    system "#{bin}/mpirun", "-n","1","shamrock","--smi","--sycl-cfg","auto:OpenMP"
  end
end
