package com.raogaru.raoctl.oracle.deploy;
 
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.CommandLineRunner;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.annotation.Bean;
import org.springframework.core.task.TaskExecutor;
import org.springframework.scheduling.annotation.EnableAsync;
import org.springframework.scheduling.concurrent.ThreadPoolTaskExecutor;
import com.raogaru.raoctl.oracle.deploy.ArbitraryRepository;
import com.raogaru.raoctl.oracle.deploy.ExecuteSQL;
import com.raogaru.raoctl.oracle.deploy.WatchDir;
import javax.sql.DataSource;
import static java.lang.System.exit;
import java.nio.file.Path;
import java.nio.file.Paths;
 
@SpringBootApplication
@EnableAsync
public class SpringBootConsoleApplication implements CommandLineRunner{
 
	@Autowired DataSource dataSource;
	@Autowired ArbitraryRepository arbitraryRepository;
	@Autowired WatchDir watchDir;

	public static void main(String[] args) throws Exception {
		SpringApplication app = new SpringApplication(SpringBootConsoleApplication.class);
 		app.run(args);
	}
 
	@Bean(name = "arbitraryRepository")
	public TaskExecutor taskExecutor() {
		ThreadPoolTaskExecutor executor = new ThreadPoolTaskExecutor();
		executor.setCorePoolSize(10);
		executor.setMaxPoolSize(20);
		executor.setQueueCapacity(10);
		return executor;
	}

	@Override
	public void run(String... args) throws Exception {
		Path dir = Paths.get("/tmp/sql");
		System.out.println("Watching dir = "+dir.toAbsolutePath());
		watchDir.initialize(dir,false).processEvents();
		exit(0);
	}
}
