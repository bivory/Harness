#!/usr/bin/env ruby

require "date"
require "fileutils"

class Command
  Tests = "tests"
  Results = "results"
  ResultsExpected = Results + "/expected"
  ResultPre = "run_"
  ResultExt = ".result"
  FailedResultExt = ".failedresult"

  def initialize()
    @time = DateTime.now.strftime("%Y.%m.%d-%H.%M.%S")
  end

  def description() "" end
  def options() nil end
  def run() end

  def get_tests(path=Tests) Dir.glob(path + '/*').select{|f| File.extname(f) != ResultExt} end
  def get_unclassified() get_tests.reject{|f|
    File.file?(get_file_expected_result(f)) or File.exists?(get_last_failed_result(f))
  }
  end
  def get_last_run_tests() get_tests.select{|f| File.file?(get_last_result(f))} end
  def get_unrun() get_tests.reject{|f|
    File.file?(get_last_result(f)) or File.file?(get_last_failed_result(f))
  }
  end

  def get_last_run_test_results() get_tests.select {|f| File.exists?(get_file_expected_result(f))} end
  def get_last_run_test_failed_results() get_tests.select {|f| File.exists?(get_last_failed_result(f))} end
  def classify_test(f)
      result = get_last_result(f)
      expected = get_file_expected_result(f)
      if not File.exists?(result) then
        :unrun
      elsif not File.exists?(expected) then
        :unclassified
      else
        FileUtils.compare_file(expected, result)
      end
  end
  def get_successful() get_last_run_test_results.select{|f| classify_test(f) == true} end
  def get_unsuccessful()
    unexpected = get_last_run_test_results.select{|f| classify_test(f) == false}
    marked_failed = get_last_run_test_failed_results
    unexpected | marked_failed
  end

  def get_all() get_unrun() + get_unclassified() + get_successful() + get_unsuccessful() end

  def get_file_expected_result(path) ResultsExpected + "/" + File.basename(path) + ResultExt end

  # Get the last results directory
  def get_last_result_path()
    runs = Dir.new(Results).select{|f| File.fnmatch(ResultPre + "*", f)}
    latest = runs.sort.last
    if latest.nil? then nil else Results + "/" + runs.sort.last end
  end
  def get_last_result(path)
    if get_last_result_path.nil?
      ""
    else
      get_last_result_path + "/" + File.basename(path) + ResultExt
    end
  end
  def get_last_failed_result(path)
    if get_last_result_path.nil?
      ""
    else
      get_last_result_path + "/" + File.basename(path) + FailedResultExt
    end
  end

  # Get the output results directory
  def get_result_out_path() Results + "/" + ResultPre + @time + "/" end
  def get_file_result_out_path(path) get_result_out_path() + File.basename(path) + ResultExt end
end

class CommandResults < Command
  def description() "Print the test results." end
  def options() {"-v" => "Verbose file printing."} end

  def print_results_for(title, files, verbose)
    printf "%s (%d)\n", title, files.length
    if verbose
      files.select{|f| puts f}
      print "\n"
    end
  end

  def run(args, commands)
    if get_last_result_path() == nil then
      puts "There are no results. Please run the tests first."
      return
    end
    verbose = args[1] == "-v"
    printf "Latest results: %s\n", get_last_result_path
    print_results_for("Unclassified Tests", get_unclassified(), verbose)
    print_results_for("Successful Tests", get_successful(), verbose)
    print_results_for("Unsuccessful Tests", get_unsuccessful(), verbose)
    print_results_for("Unrun Tests", get_unrun(), verbose)
    printf "Total (%d)\n", get_all().length
  end
end

class CommandClassify < Command
  def description()
    "Classify a result.\n" +
      "   ex: classify success <file>\n" +
      "   ex: classify success"
  end
  def options() {
    "success" => "Mark test successful.",
    "failed" => "Mark test failed."
  }
  end

  def run(args, commands)
    if get_last_result_path() == nil then
      puts "There are no results. Please run the tests first."
      return
    end
    case
    when args[1] == "success"
      puts "Marking tests as successful..."
    when args[1] == "failed"
      puts "Marking tests as unsuccessful..."
    else
      puts "Please specify success or failed."
      return
    end
    if args[2].nil?
      files = get_unclassified()
    else
      files = args.drop 2
    end
    files.select{|f|
      result = get_last_result f
      if args[1] == "success" then
        FileUtils.copy(result, get_file_expected_result(f))
      else
        FileUtils.move(result, get_last_failed_result(f))
      end
    }
  end
end

class CommandRun < Command
  def description() "Run the unclassified tests." end

  def options() {
    "all" => "Run all the tests.",
    "failed" => "Run just the failed tests.",
    "unclassified" => "Run just the failed tests.",
    "new" => "Run just the new tests (default)."
  }
  end

  def run(args, commands)
    case
    when args[1] == "failed"
      puts "Running failed tests..."
      tests = get_unsuccessful()
    when args[1] == "unclassified"
      puts "Running unclassified tests..."
      tests = get_unclassified()
    else
      puts "Running all tests..."
      tests = get_all()
    end
    # Create the results directory
    results_dir = get_result_out_path()
    Dir.mkdir results_dir, 0777

    # Run the tests and write out the results
    tests.select{|t|
      result = eval_script t, nil
      write_result t, result
    }
    puts "Done."
  end

  def eval_script filename, arguments
    proc = Proc.new {}
    eval(File.read(filename), proc.binding, filename)
  end

  def write_result filename, result
    output = File.open(get_file_result_out_path(filename), "w+")
    output << result
    output.close
  end
end

class CommandHelp < Command
  def description() "Print this help message." end
  def run(args, commands)
    puts "=== VALID HARNESS COMMANDS ==="
    commands.each{|k,v|
      puts k + ": " + v.description()
      options = v.options()
      unless options.nil?
        options.each{|opt, descr| puts "\t" + opt + ": " + descr}
      end
    }
  end
end

class Harness
  Commands = {
    "classify"  => CommandClassify.new(),
    "run"       => CommandRun.new(),
    "results"   => CommandResults.new(),
    "help"      => CommandHelp.new()
  }

  def run(args)
    command = Commands[args[0]]
    command = Commands["help"] if command.nil?
    command.run(args, Commands)
  end
end

harness = Harness.new()
harness.run ARGV
