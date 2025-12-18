package com.demo.jdemo.controller;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.PostMapping;
import com.demo.jdemo.dto.HelloRequest;
import com.demo.jdemo.dto.HelloQuery;
import jakarta.validation.Valid;

@RestController
public class HelloController {
    // GET - 接收Query參數
    @GetMapping("/hello")
    public String getHello(@RequestParam("name") String name, @RequestParam("age") Integer age) {
        HelloQuery query = new HelloQuery();
        query.setName(name);
        query.setAge(age);
        return query.helloGetResponse();
    }
    
    // POST - 接收Body（JSON）
    @PostMapping("/hello")
    public String postHello(@Valid @RequestBody HelloRequest request) {
        return request.helloPostResponse();
    }

    @GetMapping("/goodbye")
    public String goodbye() {
        return "Goodbye from Java!";
    }

    @GetMapping("/user")
    public String user() {
        return "User from Java!";
    }
}