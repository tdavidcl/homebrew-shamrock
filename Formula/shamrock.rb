class Shamrock < Formula
  desc "Astrophysical hydrodynamics using SYLC"
  homepage "https://github.com/Shamrock-code/Shamrock"
  url "https://github.com/Shamrock-code/Shamrock/releases/download/v2025.03.1/shamrock-2025.03.1.tar"
  sha256 "5309b09e5c2386666f5c63405d35fa5f63d8af2a1acb90b15b057805fe128720"
  license "BSD-2-Clause"

  depends_on "cmake" => :build
  depends_on "fmt"
  depends_on "open-mpi"
  depends_on "python"
  depends_on "adaptivecpp"

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
    system "#{bin}/acpp", "--version"

    (testpath/"hellosycl.cpp").write <<~C
      #include <sycl/sycl.hpp>
      int main(){
          sycl::queue q{};
      }
    C
    system bin/"acpp", "hellosycl.cpp", "-o", "hello"
    system "./hello"
  end
end
