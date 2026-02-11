
## 🟢 Option 1: Simple Static Website using **Nginx**

Best for hosting **HTML/CSS/JS files**

**Folder structure**

```
project/
 ├─ Dockerfile
 └─ html/
     └─ index.html
```

**index.html**

```
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>Sample Index Page</title>

  <!-- Optional CSS -->
  <style>
    body {
      font-family: Arial, Helvetica, sans-serif;
      margin: 0;
      padding: 0;
      background: #f4f4f4;
    }

    header {
      background: #333;
      color: #fff;
      padding: 1rem;
      text-align: center;
    }

    main {
      padding: 2rem;
    }

    button {
      padding: 0.5rem 1rem;
      cursor: pointer;
    }
  </style>
</head>
<body>

  <header>
    <h1>Welcome!</h1>
    <p>This is a sample index.html page</p>
  </header>

  <main>
    <h2>Hello World 👋</h2>
    <p>Edit this file to start building your website.</p>

    <button onclick="sayHello()">Click me</button>
  </main>

  <!-- Optional JavaScript -->
  <script>
    function sayHello() {
      alert("Hello from index.html!");
    }
  </script>

</body>
</html>
```


**Dockerfile**

```dockerfile
FROM nginx:alpine

# Remove default nginx website
RUN rm -rf /usr/share/nginx/html/*

# Copy your static files
COPY html/ /usr/share/nginx/html/

# Expose HTTP port
EXPOSE 80

# Start nginx
CMD ["nginx", "-g", "daemon off;"]
```

**Build & Run**

```bash
docker build -t my-http-site .
docker run -p 8080:80 my-http-site
```

Open: **[http://localhost:8080](http://localhost:8080)**

---

## 🟢 Option 2: Simple HTTP Server using **Python**

Great for quick demos or lightweight file hosting.

**Dockerfile**

```dockerfile
FROM python:3.11-slim

WORKDIR /app

# Copy files to serve
COPY . /app

EXPOSE 8000

CMD ["python", "-m", "http.server", "8000"]
```

**Build & Run**

```bash
docker build -t python-http .
docker run -p 8000:8000 python-http
```

Open: **[http://localhost:8000](http://localhost:8000)**

---

## 🟢 Option 3: Apache HTTP Server

If you prefer Apache instead of Nginx.

```dockerfile
FROM httpd:alpine

COPY ./html/ /usr/local/apache2/htdocs/

EXPOSE 80
```

Run:

```bash
docker build -t apache-http .
docker run -p 8080:80 --name httpd01 apache-http
```

---

## 🚀 Which One Should You Use?

| Use Case                 | Best Choice |
| ------------------------ | ----------- |
| Static website           | Nginx       |
| Quick local file server  | Python      |
| Apache-based environment | Apache      |

