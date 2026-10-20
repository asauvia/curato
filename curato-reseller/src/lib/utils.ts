import { clsx, type ClassValue } from "clsx"
import { twMerge } from "tailwind-merge"

export function cn(...inputs: ClassValue[]) {
  return twMerge(clsx(inputs))
}

export function formatCurrency(amount: number): string {
  return new Intl.NumberFormat("en-IN", {
    style: "currency",
    currency: "INR",
    maximumFractionDigits: 0,
  }).format(amount);
}

export function formatDate(dateStr: string): string {
  return new Date(dateStr).toLocaleDateString("en-IN", {
    day: "2-digit",
    month: "short",
    year: "numeric",
  });
}

export function getStatusColor(status: string): string {
  switch (status) {
    // Palette: signal green for success/live, destructive for failures,
    // neutral muted panels for everything in progress or unknown.
    case "Active": return "bg-signal/10 text-signal";
    case "Approved": return "bg-signal/10 text-signal";
    case "Paid": return "bg-signal/10 text-signal";
    case "Delivered": return "bg-signal/10 text-signal";
    case "Pending": return "bg-muted text-foreground";
    case "Processing": return "bg-muted text-foreground";
    case "Returned": return "bg-muted text-muted-foreground";
    case "Suspended": return "bg-destructive/10 text-destructive";
    case "Rejected": return "bg-destructive/10 text-destructive";
    case "Cancelled": return "bg-destructive/10 text-destructive";
    default: return "bg-muted text-muted-foreground";
  }
}
