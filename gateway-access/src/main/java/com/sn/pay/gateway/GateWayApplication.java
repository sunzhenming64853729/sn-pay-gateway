package com.sn.pay.gateway;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.cloud.client.discovery.EnableDiscoveryClient;

/**
 * @author ipaynow0531
 * @date 2019/6/11/10:29
 */
@EnableDiscoveryClient
@SpringBootApplication
public class GateWayApplication {

    private static final Logger LOGGER = LoggerFactory.getLogger(GateWayApplication.class);

    public static void main(String[] args) {
        SpringApplication.run(GateWayApplication.class, args);

        LOGGER.info("应用启动完成");
    }

}
