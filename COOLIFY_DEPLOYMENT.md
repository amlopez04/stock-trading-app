# Coolify Deployment Guide

This guide will help you deploy the Stock Trading App to Coolify.

## Prerequisites

1. A Coolify instance running (self-hosted or Coolify Cloud)
2. Your code pushed to a Git repository (GitHub, GitLab, or Gitea)
3. Access to your Coolify dashboard

## Deployment Options

### Option 1: Using Docker Compose (Recommended)

Coolify can automatically detect and use `docker-compose.yml` files.

#### Steps:

1. **Connect Repository**
   - In Coolify, go to "Resources" → "New Resource"
   - Select "Docker Compose"
   - Connect your Git repository
   - Coolify will detect the `docker-compose.yml` file

2. **Configure Environment Variables**
   - Add all required environment variables in Coolify's environment section
   - See `.env.example` for a complete list
   - **Important variables:**
     - `RAILS_MASTER_KEY` - Get from `config/master.key`
     - `DATABASE_URL` - Will be auto-generated if using Coolify's PostgreSQL service
     - `FINNHUB_API_KEY` - Your Finnhub API key
     - `SMTP_PASSWORD` - Your Resend API key (if using Resend)
     - `RAILS_HOST` - Your domain (e.g., `app.yourdomain.com`)

3. **Deploy**
   - Click "Deploy"
   - Coolify will build and start all services (web, worker, db)

### Option 2: Using Dockerfile (Single Service)

If you prefer to deploy without docker-compose:

1. **Create PostgreSQL Database**
   - In Coolify, create a PostgreSQL database resource
   - Note the connection string

2. **Create Web Application**
   - Go to "Resources" → "New Resource" → "Application"
   - Connect your Git repository
   - Coolify will detect the `Dockerfile`
   - Set the **Port** to `3000`
   - Set the **Start Command** to: `./bin/rails server -b 0.0.0.0`

3. **Create Background Worker**
   - Create another application resource
   - Use the same repository
   - Set the **Start Command** to: `bundle exec bin/jobs`
   - Use the same environment variables as the web service

4. **Configure Environment Variables**
   - Add all required environment variables
   - Set `DATABASE_URL` to the PostgreSQL connection string from step 1

## Required Environment Variables

Copy these into Coolify's environment variables section:

```bash
RAILS_ENV=production
RAILS_MASTER_KEY=<from config/master.key>
DATABASE_URL=<postgresql://user:pass@host:5432/dbname>
RAILS_HOST=<your-domain.com>
FINNHUB_API_KEY=<your-finnhub-key>
SMTP_ADDRESS=smtp.resend.com
SMTP_PORT=587
SMTP_USERNAME=resend
SMTP_PASSWORD=<your-resend-key>
SMTP_DOMAIN=<your-domain.com>
MAILER_SENDER=pnmstocktrading@deidei.tech
RAILS_MAX_THREADS=5
SOLID_QUEUE_IN_PUMA=true
JOB_CONCURRENCY=1
PORT=3000
```

## Database Setup

### Using Coolify's PostgreSQL Service:

1. Create a PostgreSQL database in Coolify
2. Coolify will provide a connection string
3. Use that as your `DATABASE_URL`

### Using External Database:

If you have an external PostgreSQL database, just set `DATABASE_URL` to the connection string.

## Running Migrations

Migrations will run automatically on first deploy via the `docker-entrypoint` script. If you need to run them manually:

1. Go to your web service in Coolify
2. Open the "Terminal" tab
3. Run: `bundle exec rails db:migrate`
4. If you have queue migrations: `bundle exec rails db:migrate:queue`

## Background Jobs

The `docker-compose.yml` includes a separate worker service that runs Solid Queue jobs. If you're using the single-service approach, set `SOLID_QUEUE_IN_PUMA=true` to run jobs in the web process.

## SSL/HTTPS

Coolify automatically handles SSL certificates via Let's Encrypt. Just:
1. Add your domain in Coolify
2. Enable SSL
3. Coolify will automatically provision certificates

## Troubleshooting

### Build Fails
- Check that all environment variables are set
- Verify `RAILS_MASTER_KEY` is correct
- Check build logs in Coolify

### Database Connection Issues
- Verify `DATABASE_URL` is correct
- Ensure database service is running
- Check network connectivity between services

### Jobs Not Running
- If using docker-compose, ensure the worker service is running
- Check worker logs in Coolify
- Verify `FINNHUB_API_KEY` is set

### Port Issues
- Ensure the application listens on `0.0.0.0` (not `localhost`)
- Verify port is set to `3000` in environment variables
- Check Coolify's port configuration matches

## Updating the Application

1. Push changes to your Git repository
2. In Coolify, click "Redeploy" on your services
3. Coolify will pull the latest code and rebuild

## Monitoring

- Check logs in Coolify's dashboard
- Monitor resource usage (CPU, Memory)
- Set up health checks using `/up` endpoint

## Additional Notes

- The `docker-compose.yml` includes persistent volumes for storage and tmp directories
- The database uses a persistent volume for data
- All services are configured to restart automatically unless stopped

