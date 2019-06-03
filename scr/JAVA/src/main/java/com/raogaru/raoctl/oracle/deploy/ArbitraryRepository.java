package com.raogaru.raoctl.oracle.deploy;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Repository;
import java.util.List;

@Repository
public class ArbitraryRepository {

  @Autowired
  private JdbcTemplate jdbcTemplate;

  public List<Object> executeSQL(String sql) {
      long t1 = System.nanoTime();
      List Results = jdbcTemplate.queryForList(sql);
        long t2 = System.nanoTime();
        System.out.println("SQL ::"+sql+":: time to execute in nano seconds ="+ (t2-t1));
        return Results;
  }
}
