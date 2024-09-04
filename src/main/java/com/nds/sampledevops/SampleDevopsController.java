package com.nds.sampledevops;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.http.MediaType;

@RestController
@RequestMapping("/")
public class SampleDevopsController {

    @GetMapping(value="/", produces = MediaType.TEXT_HTML_VALUE) 
    public String getSample() {

        System.out.println("http_get_success"          
        );
        return "<html><body><h1>Welcome to my SampleDevOps SpringBoot Java Application!</h1></body></html>";
    }
}