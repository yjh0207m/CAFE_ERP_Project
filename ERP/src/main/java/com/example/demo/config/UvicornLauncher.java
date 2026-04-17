package com.example.demo.config;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.DisposableBean;
import org.springframework.boot.context.event.ApplicationReadyEvent;
import org.springframework.context.ApplicationListener;
import org.springframework.stereotype.Component;

import java.io.File;
import java.net.Socket;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.concurrent.TimeUnit;

/**
 * Spring Boot 시작 시 DAP(분석 서버) uvicorn 프로세스를 자동으로 시작/종료합니다.
 * DAP 폴더는 Spring 프로젝트 루트(ERP/) 하위에 위치해야 합니다.
 *   예: ERP/DAP/server.py
 */
@Component
public class UvicornLauncher implements ApplicationListener<ApplicationReadyEvent>, DisposableBean {

    private static final Logger log = LoggerFactory.getLogger(UvicornLauncher.class);
    private static final int    DAP_PORT   = 8000;
    private static final String DAP_HOST   = "127.0.0.1";

    private Process uvicornProcess;

    @Override
    public void onApplicationEvent(ApplicationReadyEvent event) {
        // Spring 프로젝트 루트 기준으로 DAP 폴더 탐색
        Path dapDir = Paths.get(System.getProperty("user.dir"), "DAP");
        File dapDirFile = dapDir.toFile();

        if (!dapDirFile.exists() || !dapDirFile.isDirectory()) {
            log.warn("[DAP] DAP 폴더를 찾을 수 없습니다 (경로: {}). 분석 서버를 시작하지 않습니다.", dapDir);
            return;
        }

        if (isPortInUse(DAP_PORT)) {
            log.info("[DAP] 포트 {}이 이미 사용 중입니다. 분석 서버가 이미 실행 중인 것으로 판단합니다.", DAP_PORT);
            return;
        }

        String python = findPython();
        if (python == null) {
            log.warn("[DAP] Python 실행파일을 찾을 수 없습니다. 분석 서버를 시작할 수 없습니다.");
            return;
        }

        try {
            File logFile = new File(dapDirFile, "uvicorn.log");
            ProcessBuilder pb = new ProcessBuilder(
                python, "-m", "uvicorn", "server:app",
                "--host", DAP_HOST,
                "--port", String.valueOf(DAP_PORT)
            );
            pb.directory(dapDirFile);
            pb.redirectErrorStream(true);
            pb.redirectOutput(logFile);   // DAP/uvicorn.log 에 출력 기록

            uvicornProcess = pb.start();
            log.info("[DAP] 분석 서버 시작 완료 — PID: {}, 경로: {}, 로그: {}",
                     uvicornProcess.pid(), dapDir, logFile.getAbsolutePath());
        } catch (Exception e) {
            log.error("[DAP] 분석 서버 시작 실패: {}", e.getMessage());
        }
    }

    @Override
    public void destroy() {
        if (uvicornProcess != null && uvicornProcess.isAlive()) {
            // 자식 프로세스(uvicorn worker)도 함께 종료
            uvicornProcess.descendants().forEach(ProcessHandle::destroy);
            uvicornProcess.destroy();
            try {
                uvicornProcess.waitFor(5, TimeUnit.SECONDS);
            } catch (InterruptedException ignored) {
                Thread.currentThread().interrupt();
            }
            log.info("[DAP] 분석 서버 종료 완료");
        }
    }

    /** Python 실행파일 탐색 (PATH 기준) */
    private String findPython() {
        for (String candidate : new String[]{"python", "py", "python3"}) {
            try {
                Process p = new ProcessBuilder(candidate, "--version")
                    .redirectErrorStream(true)
                    .start();
                if (p.waitFor(3, TimeUnit.SECONDS) && p.exitValue() == 0) {
                    log.debug("[DAP] Python 실행파일 확인: {}", candidate);
                    return candidate;
                }
            } catch (Exception ignored) {}
        }
        return null;
    }

    /** 포트 사용 여부 확인 */
    private boolean isPortInUse(int port) {
        try (Socket s = new Socket(DAP_HOST, port)) {
            return true;
        } catch (Exception e) {
            return false;
        }
    }
}
