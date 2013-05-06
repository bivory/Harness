#!/usr/bin/env ruby

class Command
  Tests = {
    "unclassified" => "unclassified",
    "successful"  => "successful",
    "unsuccessful" =>  "failed"
  }

  def description() "" end
  def options() nil end
  def run() end

  def get_files(path) Dir.glob(path + '/*') end
  def get_unclassified() get_files(Tests["unclassified"]) end
  def get_successful() get_files(Tests["successful"]) end
  def get_unsuccessful() get_files(Tests["unsuccessful"]) end
  def get_all() get_unclassified() + get_successful() + get_unsuccessful() end
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
    verbose = args[1] == "-v"
    print_results_for("Unclassified Tests", get_unclassified(), verbose)
    print_results_for("Successful Tests", get_successful(), verbose)
    print_results_for("Unsuccessful Tests", get_unsuccessful(), verbose)
    printf "Total (%d)\n", get_all().length
  end
end

class CommandRun < Command
  def description() "Run the unclassified tests." end

  def options() {
    "all" => "Run all the tests.",
    "failed" => "Run just the failed tests.",
  }
  end

  def run(args, commands)
    case
    when args[1] == "all"
      puts "Running all tests..."
      tests = get_all()
    when args[1] == "failed"
      puts "Running failed tests..."
      tests = get_unsuccessful()
    else
      puts "Running unclassified tests..."
      tests = get_unclassified()
    end
    tests.select{|t|
      puts t
      result = eval_script t, nil
      puts result
    }
    puts "Done."
  end

  def eval_script filename, arguments
    proc = Proc.new {}
    eval(File.read(filename), proc.binding, filename)
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
    "run" => CommandRun.new(),
    "results" => CommandResults.new(),
    "help"    => CommandHelp.new()
  }

  def run(args)
    command = Commands[args[0]]
    command = Commands["help"] if command.nil?
    command.run(args, Commands)
  end
end

harness = Harness.new()
harness.run ARGV
