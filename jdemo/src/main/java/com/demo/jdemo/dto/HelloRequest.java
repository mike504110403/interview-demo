package com.demo.jdemo.dto;

import jakarta.validation.constraints.*;
import lombok.Data;

@Data
public class HelloRequest {
    
    // 必填 + 長度限制
    @NotBlank(message = "名字不能為空")
    @Size(min = 2, max = 20, message = "名字長度必須在2-20之間")
    private String name;
    
    // 必填 + 範圍限制
    @NotNull(message = "年齡不能為空")
    @Min(value = 1, message = "年齡必須大於0")
    @Max(value = 150, message = "年齡必須小於150")
    private Integer age;
    
    // 可選 + Email格式驗證
    @Email(message = "Email格式不正確")
    private String email;
    
    // 可選字段（沒有@NotNull就是可選）
    private String address;
    
    public String helloPostResponse() {
        return "Hello " + name + ", " + age + "歲!";
    }
}