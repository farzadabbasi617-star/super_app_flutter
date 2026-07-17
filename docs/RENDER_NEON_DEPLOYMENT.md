# 🚀 Guide to Deploying Super App on Neon & Render

This guide provides step-by-step instructions for deploying the **Super App Flutter** project with a Node.js backend API on **Render** (render.com) and connecting it to a **Neon** (neon.tech) Serverless PostgreSQL database.

---

## 🗄️ Step 1: Set up Neon PostgreSQL Database

1. Go to [Neon Console](https://console.neon.tech/) and create a free project (e.g., `super-app-db`).
2. Once your database is created, copy your **Connection String** (which looks like: `postgresql://user:password@ep-cool-name-123456.eu-central-1.aws.neon.tech/neondb?sslmode=require`).
3. Open the **SQL Editor** in Neon and run the SQL queries from `backend/schema.sql` to create tables and seed initial mock data (shops, products, users).

---

## ☁️ Step 2: Deploy on Render via `render.yaml` (Blueprint)

1. Push your repository to GitHub (`farzadabbasi617-star/super_app_flutter`).
2. Go to [Render Dashboard](https://dashboard.render.com/).
3. Click on **New** -> **Blueprint**.
4. Connect your GitHub repository `super_app_flutter`.
5. Render will automatically detect the `render.yaml` file containing two services:
   - **`super-app-backend`**: Node.js API service located in `backend/`.
   - **`super-app-frontend`**: Flutter Web static site.
6. When prompted for environment variables, set `DATABASE_URL` to your Neon PostgreSQL connection string.
7. Click **Apply Blueprint**. Render will build and deploy both your backend API and your high-performance Flutter Web application!

---

## 🛠️ Local Development & Testing

If you want to run the backend API locally:

```bash
cd backend
npm install
cp .env.example .env   # Add your Neon DATABASE_URL
npm start
```

For running Flutter Web locally:
```bash
flutter pub get
flutter run -d chrome
```
