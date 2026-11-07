CREATE EXTENSION IF NOT EXISTS "pgcrypto";
CREATE EXTENSION IF NOT EXISTS "citext";

CREATE TYPE "TaskPriority" AS ENUM ('low', 'medium', 'high');
CREATE TYPE "TaskStatus" AS ENUM ('todo', 'in_progress', 'done');

CREATE TABLE "users" (
  "id" UUID NOT NULL DEFAULT gen_random_uuid(),
  "auth_subject" TEXT NOT NULL,
  "email" CITEXT NOT NULL,
  "timezone" TEXT NOT NULL DEFAULT 'UTC',
  "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "updated_at" TIMESTAMPTZ(6) NOT NULL,
  CONSTRAINT "users_pkey" PRIMARY KEY ("id")
);
CREATE UNIQUE INDEX "users_auth_subject_key" ON "users"("auth_subject");
CREATE UNIQUE INDEX "users_email_key" ON "users"("email");

CREATE TABLE "tasks" (
  "id" UUID NOT NULL DEFAULT gen_random_uuid(),
  "user_id" UUID NOT NULL,
  "title" VARCHAR(200) NOT NULL,
  "description" VARCHAR(5000),
  "priority" "TaskPriority" NOT NULL DEFAULT 'medium',
  "status" "TaskStatus" NOT NULL DEFAULT 'todo',
  "due_at" TIMESTAMPTZ(6),
  "completed_at" TIMESTAMPTZ(6),
  "deleted_at" TIMESTAMPTZ(6),
  "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "updated_at" TIMESTAMPTZ(6) NOT NULL,
  CONSTRAINT "tasks_pkey" PRIMARY KEY ("id"),
  CONSTRAINT "tasks_title_trimmed_nonblank" CHECK (length(btrim("title")) BETWEEN 1 AND 200),
  CONSTRAINT "tasks_description_limit" CHECK ("description" IS NULL OR length("description") <= 5000),
  CONSTRAINT "tasks_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE
);
CREATE INDEX "tasks_user_deleted_status_idx" ON "tasks"("user_id", "deleted_at", "status");
CREATE INDEX "tasks_user_deleted_due_idx" ON "tasks"("user_id", "deleted_at", "due_at");
