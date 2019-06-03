package com.raogaru.raoctl.oracle.deploy;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.List;
import java.util.stream.Stream;
import javax.sql.DataSource;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Component;
import com.raogaru.raoctl.oracle.deploy.ArbitraryRepository;

@Component
public class ExecuteSQL {

	@Autowired ArbitraryRepository arbitraryRepository;

	@Autowired DataSource dataSource;

	@Async("arbitraryTaskExecutor")
	public Object executeFormFile(Path file) {
		readFile(file);
		return null;
	}

	private void readFile(Path file) {
		try (Stream<String> stream = Files.lines(file)) {
			stream.forEach(sql -> {
				System.out.println("Executing SQL...");
				List<Object> list = arbitraryRepository.executeSQL(sql);
				list.forEach(x -> System.out.println(x));
				System.out.println("Done");
				});
		} catch (IOException e) {
			e.printStackTrace();
		}
	}
}
