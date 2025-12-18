package com.demo.jdemo.dto;

import lombok.Data;

@Data
public class HelloQuery {
    private String name;
    private Integer age;
    
    public String helloGetResponse() {
        return "GET Hello: " + name + ", age: " + age + "!";
    }
}