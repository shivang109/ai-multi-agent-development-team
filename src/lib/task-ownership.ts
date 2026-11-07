import { Prisma } from "@prisma/client";

/** Include this predicate in every ordinary task read, write, list and aggregate. */
export function ownedActiveTaskWhere(userId: string, taskId?: string) {
  return {
    userId,
    deletedAt: null,
    ...(taskId ? { id: taskId } : {}),
  } satisfies Prisma.TaskWhereInput;
}

/** Restore is the sole task lookup that includes deleted rows; still bind both owner and ID. */
export function ownedTrashTaskWhere(userId: string, taskId: string) {
  return { userId, id: taskId, deletedAt: { not: null } } satisfies Prisma.TaskWhereInput;
}
