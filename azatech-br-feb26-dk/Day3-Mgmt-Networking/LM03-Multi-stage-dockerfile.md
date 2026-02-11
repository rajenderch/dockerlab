
## LAB MANUAL: Multi-Stage Dockerfile for Java WAR → Tomcat

### Lab Duration

**60–90 minutes**

### Audience / Prerequisites

* Basic Maven (pom.xml, mvn package)
* Basic Docker (build/run/logs)
* Java web app outputs a **WAR** file

### Lab Goal

Build the application in a **builder stage** (Maven) → copy only the WAR into a **Tomcat runtime stage** → run container and validate the app.

---

## 1) Assumptions (Important)

1. You already have:

   * `pom.xml`
   * Java source code under `src/`
2. Packaging type in `pom.xml` is **war**:

   ```xml
   <packaging>war</packaging>
   ```
3. Final artifact will be something like:

   * `target/<app-name>.war`
4. You will run the WAR in Tomcat using:

   * `webapps/ROOT.war` (so the app opens at `/`)

---

## 2) Lab Folder Structure (Expected)

Your project root should look like:

```
my-java-war-app/
├─ pom.xml
├─ src/
│  └─ main/...
└─ Dockerfile
```

* Note: use the samplemaven folder for the same

---

## 3) Step 1 — Validate WAR Build Locally (Optional but Recommended)

From project root:

```bash
mvn -v
mvn clean package
```

Confirm the WAR exists:

```bash
ls -lh target/*.war
```

If WAR is not generated, check `pom.xml` packaging and plugins.

---

## 4) Step 2 — Create a Multi-Stage Dockerfile (Builder + Runtime)

Create `Dockerfile` in project root:

```dockerfile
# =========================================================
# STAGE 1: Build the WAR using Maven
# =========================================================
FROM maven:3.9-eclipse-temurin-17 AS builder

WORKDIR /app

# Copy pom.xml first to leverage Docker cache for dependencies
COPY pom.xml .

# Download dependencies first (faster rebuilds)
RUN mvn -B -q -e -DskipTests dependency:go-offline

# Now copy the source
COPY src ./src

# Build WAR
RUN mvn -B -q clean package -DskipTests

# =========================================================
# STAGE 2: Run the WAR in Tomcat
# =========================================================
FROM tomcat:10.1-jdk17-temurin

# Clean default webapps (optional, keeps image clean)
RUN rm -rf /usr/local/tomcat/webapps/*

# Copy WAR from builder stage as ROOT.war
COPY --from=builder /app/target/*.war /usr/local/tomcat/webapps/ROOT.war

EXPOSE 8080

# Tomcat default CMD runs automatically
```

### Why this is “multi-layer / multi-stage”

* **Stage 1** has Maven + build tools (heavy)
* **Stage 2** has only Tomcat + JDK (lighter)
* Final image does **not** contain Maven cache, source, etc.

---

## 5) Step 3 — Build the Docker Image

From project root (where Dockerfile is present):

```bash
docker build -t my-war-tomcat:1.0 .
```

Verify image:

```bash
docker images | grep my-war-tomcat
```

---

## 6) Step 4 — Run the Container

```bash
docker run -d --name myapp -p 8080:8080 my-war-tomcat:1.0
```

Check logs:

```bash
docker logs -f myapp
```

---

## 7) Step 5 — Validate Application

Open in browser:

* `http://localhost:8080/`

If your app uses a context path normally, we deployed as **ROOT** so it should open directly at `/`.

---

## 8) Troubleshooting Cheatsheet

### A) WAR not found / copy fails

If build produces `target/app.war` but Docker copy fails:

* Confirm build inside Docker succeeded:

  ```bash
  docker build --no-cache -t my-war-tomcat:debug .
  ```

### B) App opens 404

* Your WAR might not be a valid webapp
* Check Tomcat logs:

  ```bash
  docker logs myapp | tail -200
  ```

### C) Port conflict

If 8080 is already in use:

```bash
docker run -d --name myapp -p 9090:8080 my-war-tomcat:1.0
```

Then use `http://localhost:9090/`

### D) Using Tomcat 9 vs 10 confusion

* Tomcat **10+** uses **Jakarta** namespace (`jakarta.*`)
* Tomcat **9** uses older `javax.*`
  If your application is still `javax.*`, use:

```dockerfile
FROM tomcat:9.0-jdk17-temurin
```

---

## 9) Lab Exercises (Student Tasks)

### Exercise 1 — Reduce Build Time using Cache

* Ensure `pom.xml` is copied first
* Ensure `dependency:go-offline` runs before source copy
* Make a small source change, rebuild, notice speed improvement

### Exercise 2 — Deploy as named context (Not ROOT)

Instead of ROOT.war:

```dockerfile
COPY --from=builder /app/target/*.war /usr/local/tomcat/webapps/myapp.war
```

Now access:

* `http://localhost:8080/myapp/`

### Exercise 3 — Enable Health Check

Add to runtime stage:

```dockerfile
HEALTHCHECK --interval=30s --timeout=5s --start-period=30s --retries=3 \
  CMD curl -fsS http://localhost:8080/ || exit 1
```

---

## 10) Deliverables Checklist

* ✅ Multi-stage `Dockerfile`
* ✅ Docker image built successfully
* ✅ Container runs and serves app from Tomcat
* ✅ Logs validated, troubleshooting understood

