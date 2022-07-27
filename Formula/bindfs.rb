class MacfuseRequirement < Requirement
  fatal true

  satisfy(build_env: false) { self.class.binary_macfuse_installed? }

  def self.binary_macfuse_installed?
    File.exist?("/usr/local/include/fuse/fuse.h") &&
      !File.symlink?("/usr/local/include/fuse")
  end

  env do
    ENV.append_path "PKG_CONFIG_PATH",
                    "/usr/local/lib/pkgconfig:#{HOMEBREW_PREFIX}/lib/pkgconfig:"\
                    "#{HOMEBREW_PREFIX}/opt/openssl@1.1/lib/pkgconfig"
    ENV.append_path "BORG_OPENSSL_PREFIX", "#{HOMEBREW_PREFIX}/opt/openssl@1.1/"

    unless HOMEBREW_PREFIX.to_s == "/usr/local"
      ENV.append_path "HOMEBREW_LIBRARY_PATHS", "/usr/local/lib"
      ENV.append_path "HOMEBREW_INCLUDE_PATHS", "/usr/local/include/fuse"
    end
  end

  def message
    "macFUSE is required to build bindfs. Please run `brew install --cask macfuse` first."
  end
end

class Bindfs < Formula
  desc "FUSE file system for mounting to another location"
  homepage "https://bindfs.org/"
  url "https://bindfs.org/downloads/bindfs-1.17.0.tar.gz"
  sha256 "70da57d49e7794fe54b8575bfdd6a7943aab54ada2e8e2fdf4be04e0011451dc"
  license "GPL-2.0-or-later"

  head do
    url "https://github.com/mpartel/bindfs.git"

    depends_on "autoconf" => :build
    depends_on "automake" => :build
    depends_on "libtool" => :build
  end

  depends_on "pkg-config" => :build

  def install
    args = %W[
      --disable-debug
      --disable-dependency-tracking
      --prefix=#{prefix}
    ]

    system "CFLAGS='-D_FILE_OFFSET_BITS=64 -D_DARWIN_USE_64_BIT_INODE' ./configure", *args

    system "make", "install"
  end

  def caveats
    on_macos do
      <<~EOS
        The reasons for disabling this formula can be found here:
          https://github.com/Homebrew/homebrew-core/pull/64491

        An external tap may provide a replacement formula. See:
          https://docs.brew.sh/Interesting-Taps-and-Forks
      EOS
    end
  end

  test do
    system "#{bin}/bindfs", "-V"
  end
end
