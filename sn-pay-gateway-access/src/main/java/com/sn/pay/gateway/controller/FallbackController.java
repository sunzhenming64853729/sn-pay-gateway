package com.sn.pay.gateway.controller;

import com.sn.pay.gateway.constants.SystemConstants;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

/**
 * @author ipaynow0531
 * @date 2019/07/12
 */
@RestController
public class FallbackController {

    private static final String ERROR_MSG =
        "{\"responseCode\":\"FAIL\",\"responseMsg\":\"" + SystemConstants.FAIL_MESSAGE + "\"}";

    @GetMapping("/fallback")
    public String fallback() {
        return ERROR_MSG;
    }

}