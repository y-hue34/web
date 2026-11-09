# Codyssey Mission 1

## 1. 프로젝트 개요
Windows에서 Git, VS Code, Docker Desktop을 사용해 재현 가능한 웹 서버 개발 환경을 구성하고 이미지, 컨테이너, 포트, 바인드 마운트, 볼륨, Compose, Git의 기본 동작을 검증하는 실습입니다.

## 2. 실행 환경
- OS: Windows 10 Pro (빌드 26300)
- Shell: PowerShell (VS Code 통합 터미널)
- Docker Desktop: 설치 완료, Docker CLI 사용 가능
- Git: git version 2.56.0.windows.4
- VS Code: 설치 완료
- WSL: wsl --status 확인 완료

## 3. 폴더 구조

    web/
    ├── Dockerfile
    ├── index.html
    ├── site/
    │   └── index.html
    ├── docker-compose.yml
    └── docker-compose.multi.yml

## 4. 수행 체크리스트
- [x] Git, VS Code, Docker 설치 확인
- [x] Windows CMD/PowerShell 위치·목록·생성·복사·이름 변경·삭제
- [x] Ubuntu 컨테이너 Linux 명령 및 권한 실습
- [x] Docker hello-world, images, ps, info, stats
- [x] Dockerfile 기반 NGINX 커스텀 이미지
- [x] 포트 8080, 8081 접속 및 HTTP 200 확인
- [x] 바인드 마운트 파일 준비
- [ ] 바인드 마운트 실행 후 변경 반영 검증
- [ ] Docker 볼륨 영속성 검증
- [ ] Compose 단일·멀티 서비스 실행 검증
- [ ] GitHub 원격 저장소 생성 및 push
- [ ] SSH 키 등록

## 5. Dockerfile

    FROM nginx:alpine
    LABEL org.opencontainers.image.title="codyssey-mission1-web"
    ENV APP_ENV=mission1
    COPY index.html /usr/share/nginx/html/index.html
    EXPOSE 80

가벼운 nginx:alpine을 베이스 이미지로 선택했습니다. 정적 페이지를 NGINX 기본 문서 경로에 복사하고 환경 변수와 80번 포트를 명시했습니다.

## 6. 실행 및 검증 로그

    docker build -t codyssey-web:1.0 .
    docker run -d --name codyssey-web-8080 -p 8080:80 codyssey-web:1.0
    docker run -d --name codyssey-web-8081 -p 8081:80 codyssey-web:1.0
    curl http://localhost:8080
    curl http://localhost:8081

두 포트 모두 HTTP/1.1 200 OK와 Codyssey Mission 1 HTML이 반환되었습니다.

## 7. Linux 권한 실습

Ubuntu 컨테이너에서 linux_practice.txt와 linux_dir를 만들고 다음 권한을 적용했습니다.
- 파일: chmod 644 linux_practice.txt → -rw-r--r--
- 디렉터리: chmod 755 linux_dir → drwxr-xr-x

숫자 권한은 소유자·그룹·기타 사용자 순서이며 4는 읽기, 2는 쓰기, 1은 실행입니다.

## 8. 바인드 마운트

호스트 파일은 site/index.html이며 현재 내용은 Bind Mount Version 1입니다. PowerShell에서는 CMD용 %cd% 대신 아래 명령을 사용합니다.

    docker run -d --name codyssey-bind -p 8082:80 --mount "type=bind,source=$((Get-Location).Path)\site,target=/usr/share/nginx/html" nginx:alpine
    curl http://localhost:8082

이후 site/index.html의 제목을 Bind Mount Version 2로 바꾸고 다시 curl해 변경이 즉시 반영되는지 확인합니다.

## 9. Docker 볼륨 영속성

    docker volume create codyssey-data
    docker run -d --name codyssey-vol-1 -v codyssey-data:/data ubuntu:22.04 sleep infinity
    docker exec codyssey-vol-1 bash -lc "echo persistent-data > /data/message.txt && cat /data/message.txt"
    docker rm -f codyssey-vol-1
    docker run -d --name codyssey-vol-2 -v codyssey-data:/data ubuntu:22.04 sleep infinity
    docker exec codyssey-vol-2 cat /data/message.txt

두 번째 컨테이너에서도 persistent-data가 출력되면 컨테이너와 데이터 저장소가 분리되어 영속성이 보장된 것입니다.

## 10. 트러블슈팅

### 사례 1: Docker 설치 중 VirtualMachinePlatform 오류
문제: Docker 설치 로그에 Required Windows features are not enabled: VirtualMachinePlatform이 기록됨.
원인: WSL 2에 필요한 Windows 기능이 비활성화됨.
해결: 관리자 PowerShell에서 WSL 설치 또는 기능 활성화 후 재부팅.

### 사례 2: 바인드 마운트 경로 오류
문제: PowerShell에서 %cd%\site is not a valid Windows path.
원인: %cd%는 CMD 문법이며 PowerShell에서 치환되지 않음.
해결: $((Get-Location).Path)\site를 사용하는 --mount 문법으로 변경.

## 11. 재현 방법

1. Docker Desktop을 실행합니다.
2. web 폴더에서 Dockerfile을 빌드합니다.
3. 8080 또는 8081 포트로 컨테이너를 실행합니다.
4. curl http://localhost:8080으로 응답을 확인합니다.
5. 바인드 마운트, 볼륨, Compose 명령은 위 절차를 순서대로 실행합니다.

## 12. 보안 주의

README와 로그에는 비밀번호, 토큰, 개인키를 기록하지 않습니다. 공용 PC에서는 GitHub 인증 후 저장된 자격 증명을 확인하고 실습 종료 시 로그아웃합니다.