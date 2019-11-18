require 'colorize'
require 'bolt_train_runner/conf'
require 'bolt_train_runner/session_runner'

module Commands
  def self.sessions(args, comms, session_runner)
    if args.empty? || args[0] =~ /help/i
      puts 'Command: sessions'.cyan
      puts 'Syntax: sessions <start|stop>'.cyan
      puts 'Start or stop the thread that monitors the sessions folder for sessions files. When running, this thread'.cyan
      puts 'will automatically execute the commands contained in sessions files generated by the bolt-train-api server'.cyan
      puts 'as they appear in the folder.'.cyan
      return
    end
    
    state = args[0]
    starting = state == 'start'
    if !['start','stop'].include?(state)
      puts 'Please provide either "start" or "stop"'.red
      return
    end

    unless comms
      puts 'Please connect first'.red
      return
    end

    if starting and session_runner
      puts 'Session runner thread already started'.yellow
      return session_runner
    end

    if !starting and !session_runner
      puts 'No session runner thread currently running'.yellow
      return nil
    end

    if starting
      conf = Conf.load_conf
      if args[1]
        session_dir = args[1]
        conf['session_dir'] = session_dir
        Conf.save_conf(conf)
      else
        session_dir = conf['session_dir']
        unless session_dir
          # This should be changed to pick up BOLT_TRAIN_QUEUE_DIR automatically
          print 'Please enter directory for session files [/tmp/bolt-train-queue] > '
          session_dir = gets.chomp
          session_dir = '/tmp/bolt-train-queue' if session_dir.empty?
          conf['session_dir'] = session_dir
          Conf.save_conf(conf)
        end
      end
      
      runner = SessionRunner.new(comms, session_dir)
      runner.start
      return runner
    else
      session_runner.stop
      return nil
    end
  end
end