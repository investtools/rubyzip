require 'test_helper'

class FilePermissionsTest < MiniTest::Test

  ZIPNAME = File.join(File.dirname(__FILE__), "umask.zip")
  FILENAME = File.join(File.dirname(__FILE__), "umask.txt")

  def teardown
    ::File.unlink(ZIPNAME)
    ::File.unlink(FILENAME)
  end

  if ::Zip::RUNNING_ON_WINDOWS
    # Windows tests

    DEFAULT_PERMS = 0644

    def test_windows_perms
      create_files
      assert_equal ::File.stat(FILENAME).mode, ::File.stat(ZIPNAME).mode
    end

  else
    # Unix tests

    def test_current_umask
      create_files
      assert_equal ::File.stat(FILENAME).mode, ::File.stat(ZIPNAME).mode
    end

    def test_umask_000
      set_umask(0000) do
        create_files
      end

      assert_equal ::File.stat(FILENAME).mode, ::File.stat(ZIPNAME).mode
    end

    def test_umask_066
      set_umask(0066) do
        create_files
      end

      assert_equal ::File.stat(FILENAME).mode, ::File.stat(ZIPNAME).mode
    end

    def test_umask_027
      set_umask(0027) do
        create_files
      end

      assert_equal ::File.stat(FILENAME).mode, ::File.stat(ZIPNAME).mode
    end

  end

  def create_files
    ::Zip::File.open(ZIPNAME, ::Zip::File::CREATE) do |zip|
      zip.comment = "test"
    end

    ::File.open(FILENAME, 'w') do |file|
      file << 'test'
    end
  end

  # If anything goes wrong, make sure the umask is restored.
  def set_umask(umask, &block)
    begin
      saved_umask = ::File.umask(umask)
      yield
    ensure
      ::File.umask(saved_umask)
    end
  end

end
