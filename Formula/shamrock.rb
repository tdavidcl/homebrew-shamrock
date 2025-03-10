class Shamrock < Formula
  desc "Astrophysical hydrodynamics using SYLC"
  homepage "https://github.com/Shamrock-code/Shamrock"
  url "https://github.com/Shamrock-code/Shamrock/archive/refs/tags/v2024.10.0.tar.gz"
  sha256 "3bcd94eee41adea3ccc58390498ec9fd30e1548af5330a319be8ce3e034a6a0b"
  license "BSD-2-Clause"

  depends_on "cmake" => :build
  depends_on "boost"
  depends_on "libomp"
  depends_on "llvm"
  depends_on "python"
  depends_on "tdavidcl/adaptivecpp/adaptivecpp"

  def install
    libomp_root = Formula["libomp"].opt_prefix

    puts "libomp root: #{libomp_root}"

    system "cmake", ".", *std_cmake_args, "-DOpenMP_ROOT=#{libomp_root}"
    system "make", "install"

    # Avoid references to Homebrew shims directory
    shim_references = [prefix/"etc/AdaptiveCpp/acpp-core.json"]
    inreplace shim_references, Superenv.shims_path/ENV.cxx, ENV.cxx

    # we add -I#{libomp_root}/include to default-omp-cxx-flags
    inreplace prefix/"etc/AdaptiveCpp/acpp-core.json",
      "\"default-omp-cxx-flags\" : \"", "\"default-omp-cxx-flags\" : \"-I#{libomp_root}/include "

    system "cat", prefix/"etc/AdaptiveCpp/acpp-core.json"
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
