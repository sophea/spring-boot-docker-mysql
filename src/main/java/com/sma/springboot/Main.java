package com.sma.springboot;

import java.net.InetAddress;
import java.net.UnknownHostException;
import java.text.SimpleDateFormat;
import java.util.Arrays;
import java.util.List;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.ComponentScan;
import org.springframework.http.converter.json.Jackson2ObjectMapperBuilder;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.fasterxml.jackson.annotation.JsonInclude;

@RestController
@SpringBootApplication
@ComponentScan(basePackages = { "com.sma.springboot.web", "com.sma.springboot.service", "com.sma.springboot.dao" })
public class Main {

    @RequestMapping("/")
    public List<String> home() throws UnknownHostException {
        return Arrays.asList("Update Springboot war deployment in Tomcat Docker container successfully", InetAddress
                .getLocalHost().toString());
    }

    @RequestMapping("/_ah/health")
    public String healthy() {
        // Message body required though ignored
        return "Still surviving.";
    }

    public static void main(String[] args) {
        SpringApplication.run(Main.class, args);
    }

    @Bean
    public Jackson2ObjectMapperBuilder objectMapperBuilder() {
        Jackson2ObjectMapperBuilder builder = new Jackson2ObjectMapperBuilder();

        builder.serializationInclusion(JsonInclude.Include.NON_NULL);
        builder.failOnUnknownProperties(false);
        builder.dateFormat(new SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ssZ"));
        return builder;
    }
    //
    // /**create database source bean*/
    // @Bean
    // public DataSource dataSource() {
    // final String propsFile = "db.properties";
    // final Properties props = new Properties();
    // try {
    // props.load(Thread.currentThread().getContextClassLoader().getResource(propsFile).openStream());
    // return BasicDataSourceFactory.createDataSource(props);
    // } catch (Exception e) {
    // System.out.println("Error :" + e.getMessage());
    // }
    // return null;
    // }
}
