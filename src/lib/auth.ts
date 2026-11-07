import { auth, currentUser } from "@clerk/nextjs/server";
import { db } from "@/lib/db";

export class AuthenticationError extends Error {
  constructor(
    public readonly code: "UNAUTHENTICATED" | "EMAIL_NOT_VERIFIED",
  ) {
    super(code);
  }
}

/** Resolve a verified Clerk identity to its local user. Never trust client-sent user IDs. */
export async function requireVerifiedUser() {
  const { userId } = await auth();
  if (!userId) throw new AuthenticationError("UNAUTHENTICATED");

  const clerkUser = await currentUser();
  const verifiedEmail = clerkUser?.emailAddresses.find(
    (address) =>
      address.id === clerkUser.primaryEmailAddressId &&
      address.verification?.status === "verified",
  );
  if (!clerkUser || !verifiedEmail) {
    throw new AuthenticationError("EMAIL_NOT_VERIFIED");
  }

  return db.user.upsert({
    where: { authSubject: userId },
    create: { authSubject: userId, email: verifiedEmail.emailAddress },
    update: { email: verifiedEmail.emailAddress },
    select: { id: true, authSubject: true, email: true, timezone: true },
  });
}
