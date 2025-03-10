class Shamrock < Formula
  desc "Astrophysical hydrodynamics using SYLC"
  homepage "https://github.com/Shamrock-code/Shamrock"
  url "https://github.com/Shamrock-code/Shamrock/archive/refs/tags/v2024.10.0.tar.gz"
  sha256 "dd36754d35b4e30756781b298fc57402bf48b966266924e8e6db9da86b74be56"
  license "BSD-2-Clause"

  depends_on "cmake" => :build
  depends_on "boost"
  depends_on "libomp"
  depends_on "llvm"
  depends_on "python"
  depends_on "tdavidcl/adaptivecpp/adaptivecpp"

  def install
    libomp_root = Formula["libomp"].opt_prefix
    adaptivecpp_root = Formula["adaptivecpp"].opt_prefix

    puts "libomp root: #{libomp_root}"

    system "cmake", ".", *std_cmake_args,
        "-DSHAMROCK_ENABLE_BACKEND=SYCL",
        "-DSYCL_IMPLEMENTATION=ACPPDirect",
        "-DCMAKE_CXX_COMPILER=acpp",
        "-DCMAKE_CXX_FLAGS=\"-I#{libomp_root}/include\"",
        "-DACPP_PATH=#{adaptivecpp_root}",
        "-DCMAKE_BUILD_TYPE=Release",
        "-DBUILD_TEST=Yes"
        
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
