-- CreateEnum
CREATE TYPE "Role" AS ENUM ('CITIZEN', 'POLICE', 'ORGANIZATION');

-- CreateEnum
CREATE TYPE "UserStatus" AS ENUM ('ACTIVE', 'SUSPENDED', 'DELETED');

-- CreateEnum
CREATE TYPE "ScanType" AS ENUM ('MESSAGE', 'URL', 'QR', 'UPI', 'VOICE');

-- CreateEnum
CREATE TYPE "ScanStatus" AS ENUM ('PENDING', 'PROCESSING', 'COMPLETED', 'FAILED');

-- CreateEnum
CREATE TYPE "RiskLevel" AS ENUM ('SAFE', 'LOW', 'MEDIUM', 'HIGH', 'CRITICAL');

-- CreateEnum
CREATE TYPE "ReportStatus" AS ENUM ('SUBMITTED', 'UNDER_REVIEW', 'INVESTIGATING', 'ACTION_TAKEN', 'RESOLVED', 'REJECTED', 'ARCHIVED');

-- CreateEnum
CREATE TYPE "ReportPriority" AS ENUM ('LOW', 'MEDIUM', 'HIGH', 'CRITICAL');

-- CreateEnum
CREATE TYPE "NotificationType" AS ENUM ('THREAT_ALERT', 'REPORT_UPDATE', 'SECURITY_TIP', 'SYSTEM', 'SCAN_COMPLETE');

-- CreateEnum
CREATE TYPE "NotificationSeverity" AS ENUM ('INFO', 'WARNING', 'CRITICAL');

-- CreateEnum
CREATE TYPE "InvestigationStatus" AS ENUM ('ACTIVE', 'MONITORING', 'RESOLVED', 'CRITICAL');

-- CreateEnum
CREATE TYPE "EvidenceType" AS ENUM ('PHONE', 'UPI', 'DOMAIN', 'DEVICE', 'COMPLAINT', 'SCREENSHOT', 'AUDIO', 'DOCUMENT');

-- CreateEnum
CREATE TYPE "IncidentStatus" AS ENUM ('NEW', 'UNDER_REVIEW', 'INVESTIGATING', 'ACTION_TAKEN', 'RESOLVED', 'ARCHIVED');

-- CreateEnum
CREATE TYPE "IncidentPriority" AS ENUM ('LOW', 'MEDIUM', 'HIGH', 'CRITICAL');

-- CreateEnum
CREATE TYPE "GraphEntityType" AS ENUM ('PHONE', 'EMAIL', 'UPI', 'DOMAIN', 'URL', 'IP', 'BANK_ACCOUNT', 'DEVICE', 'QR_CONTENT');

-- CreateTable
CREATE TABLE "users" (
    "id" TEXT NOT NULL,
    "email" TEXT NOT NULL,
    "passwordHash" TEXT NOT NULL,
    "role" "Role" NOT NULL DEFAULT 'CITIZEN',
    "isVerified" BOOLEAN NOT NULL DEFAULT false,
    "status" "UserStatus" NOT NULL DEFAULT 'ACTIVE',
    "lastLogin" TIMESTAMP(3),
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,
    "failedLoginAttempts" INTEGER NOT NULL DEFAULT 0,
    "lockedUntil" TIMESTAMP(3),

    CONSTRAINT "users_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "profiles" (
    "id" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "phone" TEXT,
    "avatar" TEXT,
    "location" TEXT,
    "bio" TEXT,
    "preferences" JSONB NOT NULL DEFAULT '{}',

    CONSTRAINT "profiles_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "sessions" (
    "id" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "refreshToken" TEXT NOT NULL,
    "userAgent" TEXT,
    "ipAddress" TEXT,
    "expiresAt" TIMESTAMP(3) NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "sessions_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "threat_scans" (
    "id" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "scanType" "ScanType" NOT NULL,
    "content" TEXT NOT NULL,
    "status" "ScanStatus" NOT NULL DEFAULT 'PENDING',
    "metadata" JSONB,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "threat_scans_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "threat_analyses" (
    "id" TEXT NOT NULL,
    "scanId" TEXT NOT NULL,
    "riskScore" INTEGER NOT NULL,
    "riskLevel" "RiskLevel" NOT NULL,
    "summary" TEXT NOT NULL,
    "recommendation" TEXT NOT NULL,
    "confidence" DOUBLE PRECISION NOT NULL,
    "aiModel" TEXT NOT NULL DEFAULT 'aegis-v1',
    "processingTime" INTEGER NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "threat_analyses_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "threat_indicators" (
    "id" TEXT NOT NULL,
    "analysisId" TEXT NOT NULL,
    "label" TEXT NOT NULL,
    "severity" "RiskLevel" NOT NULL,
    "confidence" DOUBLE PRECISION NOT NULL,
    "description" TEXT NOT NULL,
    "indicators" TEXT[],

    CONSTRAINT "threat_indicators_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "risk_scores" (
    "id" TEXT NOT NULL,
    "analysisId" TEXT NOT NULL,
    "overall" INTEGER NOT NULL,
    "contentRisk" INTEGER NOT NULL,
    "sourceRisk" INTEGER NOT NULL,
    "patternRisk" INTEGER NOT NULL,
    "communityRisk" INTEGER NOT NULL,
    "factors" TEXT[],
    "calculatedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "risk_scores_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "saved_websites" (
    "id" TEXT NOT NULL,
    "analysisId" TEXT NOT NULL,
    "url" TEXT NOT NULL,
    "domain" TEXT NOT NULL,
    "screenshotUrl" TEXT,
    "sslValid" BOOLEAN NOT NULL,
    "sslIssuer" TEXT,
    "sslExpiry" TIMESTAMP(3),
    "redirectChain" JSONB,
    "domainAge" TEXT,
    "reputation" INTEGER,
    "lastChecked" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "saved_websites_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "threat_reports" (
    "id" TEXT NOT NULL,
    "reportNumber" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "type" TEXT NOT NULL,
    "description" TEXT NOT NULL,
    "scammerContact" JSONB,
    "financialLoss" JSONB,
    "evidence" TEXT[],
    "status" "ReportStatus" NOT NULL DEFAULT 'SUBMITTED',
    "priority" "ReportPriority" NOT NULL DEFAULT 'MEDIUM',
    "assignedTo" TEXT,
    "aiSummary" TEXT,
    "internalNotes" TEXT[],
    "acknowledgement" TEXT,
    "scammerProfileId" TEXT,
    "occurredAt" TIMESTAMP(3),
    "resolvedAt" TIMESTAMP(3),
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "threat_reports_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "notifications" (
    "id" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "type" "NotificationType" NOT NULL,
    "title" TEXT NOT NULL,
    "message" TEXT NOT NULL,
    "severity" "NotificationSeverity" NOT NULL DEFAULT 'INFO',
    "isRead" BOOLEAN NOT NULL DEFAULT false,
    "actionUrl" TEXT,
    "relatedId" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "readAt" TIMESTAMP(3),

    CONSTRAINT "notifications_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "investigations" (
    "id" TEXT NOT NULL,
    "caseId" TEXT NOT NULL,
    "title" TEXT NOT NULL,
    "description" TEXT,
    "status" "InvestigationStatus" NOT NULL DEFAULT 'ACTIVE',
    "confidence" INTEGER NOT NULL DEFAULT 0,
    "city" TEXT,
    "assignedTo" TEXT,
    "reportId" TEXT,
    "networkId" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "investigations_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "fraud_networks" (
    "id" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "cities" TEXT[],
    "confidence" INTEGER NOT NULL DEFAULT 0,
    "nodeCount" INTEGER NOT NULL DEFAULT 0,
    "edgeCount" INTEGER NOT NULL DEFAULT 0,
    "status" TEXT NOT NULL DEFAULT 'active',
    "metadata" JSONB,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "fraud_networks_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "incidents" (
    "id" TEXT NOT NULL,
    "incidentId" TEXT NOT NULL,
    "title" TEXT NOT NULL,
    "description" TEXT,
    "priority" "IncidentPriority" NOT NULL DEFAULT 'MEDIUM',
    "severity" TEXT NOT NULL DEFAULT 'medium',
    "status" "IncidentStatus" NOT NULL DEFAULT 'NEW',
    "assignedTo" TEXT,
    "createdBy" TEXT NOT NULL,
    "resolutionSummary" TEXT,
    "evidenceCount" INTEGER NOT NULL DEFAULT 0,
    "relatedReportIds" TEXT[],
    "relatedScanIds" TEXT[],
    "relatedNodeIds" TEXT[],
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "incidents_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "incident_events" (
    "id" TEXT NOT NULL,
    "incidentId" TEXT NOT NULL,
    "eventType" TEXT NOT NULL,
    "description" TEXT NOT NULL,
    "actorId" TEXT,
    "metadata" JSONB,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "incident_events_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "evidence" (
    "id" TEXT NOT NULL,
    "type" "EvidenceType" NOT NULL,
    "value" TEXT NOT NULL,
    "description" TEXT,
    "investigationId" TEXT,
    "networkId" TEXT,
    "addedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "evidence_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "timeline_events" (
    "id" TEXT NOT NULL,
    "type" TEXT NOT NULL,
    "actorType" TEXT NOT NULL DEFAULT 'user',
    "actorId" TEXT,
    "title" TEXT NOT NULL,
    "description" TEXT,
    "severity" TEXT NOT NULL DEFAULT 'info',
    "metadata" JSONB,
    "relatedAnalysis" TEXT,
    "relatedIncident" TEXT,
    "relatedEvidence" TEXT,
    "relatedReport" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "timeline_events_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "audit_logs" (
    "id" TEXT NOT NULL,
    "userId" TEXT,
    "action" TEXT NOT NULL,
    "entity" TEXT NOT NULL,
    "entityId" TEXT,
    "details" JSONB,
    "ipAddress" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "audit_logs_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "system_settings" (
    "id" TEXT NOT NULL,
    "key" TEXT NOT NULL,
    "value" JSONB NOT NULL,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "system_settings_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "evidence_uploads" (
    "id" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "filename" TEXT NOT NULL,
    "mimeType" TEXT NOT NULL,
    "fileSize" INTEGER NOT NULL,
    "fileHash" TEXT NOT NULL,
    "storagePath" TEXT,
    "visionSummary" TEXT,
    "detectedEntities" JSONB,
    "confidence" DOUBLE PRECISION,
    "riskScore" INTEGER,
    "riskLevel" TEXT,
    "analysisId" TEXT,
    "status" TEXT NOT NULL DEFAULT 'pending_review',
    "acknowledgement" TEXT,
    "internalNotes" TEXT[],
    "assignedTo" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "reportId" TEXT,

    CONSTRAINT "evidence_uploads_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "graph_nodes" (
    "id" TEXT NOT NULL,
    "entityType" "GraphEntityType" NOT NULL,
    "value" TEXT NOT NULL,
    "normalizedVal" TEXT NOT NULL,
    "occurrences" INTEGER NOT NULL DEFAULT 1,
    "riskLevel" "RiskLevel" NOT NULL DEFAULT 'SAFE',
    "firstSeen" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "lastSeen" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "metadata" JSONB,

    CONSTRAINT "graph_nodes_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "graph_edges" (
    "id" TEXT NOT NULL,
    "fromNodeId" TEXT NOT NULL,
    "toNodeId" TEXT NOT NULL,
    "edgeType" TEXT NOT NULL,
    "weight" INTEGER NOT NULL DEFAULT 1,
    "scanId" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "graph_edges_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "scammer_profiles" (
    "id" TEXT NOT NULL,
    "phones" TEXT[],
    "emails" TEXT[],
    "upiIds" TEXT[],
    "domains" TEXT[],
    "urls" TEXT[],
    "walletIds" TEXT[],
    "aliases" TEXT[],
    "threatLevel" "RiskLevel" NOT NULL DEFAULT 'LOW',
    "occurrences" INTEGER NOT NULL DEFAULT 1,
    "totalReports" INTEGER NOT NULL DEFAULT 1,
    "reportIds" TEXT[],
    "graphNodeIds" TEXT[],
    "metadata" JSONB,
    "firstSeen" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "lastSeen" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "scammer_profiles_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "conversations" (
    "id" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "title" TEXT NOT NULL DEFAULT 'New Chat',
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "conversations_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "messages" (
    "id" TEXT NOT NULL,
    "conversationId" TEXT NOT NULL,
    "role" TEXT NOT NULL,
    "content" TEXT NOT NULL,
    "metadata" JSONB,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "messages_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "upi_reputations" (
    "id" TEXT NOT NULL,
    "upiId" TEXT NOT NULL,
    "normalizedUpi" TEXT NOT NULL,
    "riskScore" INTEGER NOT NULL DEFAULT 0,
    "reportCount" INTEGER NOT NULL DEFAULT 0,
    "firstSeen" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "lastSeen" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "status" TEXT NOT NULL DEFAULT 'CLEAN',
    "metadata" JSONB,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "upi_reputations_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "ip_history" (
    "id" SERIAL NOT NULL,
    "ip" TEXT NOT NULL,
    "firstSeen" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "lastSeen" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "count" INTEGER NOT NULL DEFAULT 1,

    CONSTRAINT "ip_history_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "ip_lookup_audit" (
    "id" SERIAL NOT NULL,
    "ip" TEXT NOT NULL,
    "looked_up_by" TEXT,
    "timestamp" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "risk_score" INTEGER,

    CONSTRAINT "ip_lookup_audit_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "ip_lists" (
    "id" SERIAL NOT NULL,
    "ip" TEXT NOT NULL,
    "list_type" TEXT NOT NULL,
    "added_by" TEXT,
    "added_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "note" TEXT,

    CONSTRAINT "ip_lists_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "suspicious_infrastructure" (
    "id" TEXT NOT NULL,
    "ip" TEXT NOT NULL,
    "latitude" DOUBLE PRECISION NOT NULL,
    "longitude" DOUBLE PRECISION NOT NULL,
    "country" TEXT NOT NULL,
    "asnOrganization" TEXT,
    "riskLevel" "RiskLevel" NOT NULL DEFAULT 'SAFE',
    "linkedDomains" TEXT[],
    "firstSeen" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "lastSeen" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "suspicious_infrastructure_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "users_email_key" ON "users"("email");

-- CreateIndex
CREATE INDEX "users_email_idx" ON "users"("email");

-- CreateIndex
CREATE INDEX "users_role_status_idx" ON "users"("role", "status");

-- CreateIndex
CREATE UNIQUE INDEX "profiles_userId_key" ON "profiles"("userId");

-- CreateIndex
CREATE UNIQUE INDEX "sessions_refreshToken_key" ON "sessions"("refreshToken");

-- CreateIndex
CREATE INDEX "sessions_userId_idx" ON "sessions"("userId");

-- CreateIndex
CREATE INDEX "sessions_expiresAt_idx" ON "sessions"("expiresAt");

-- CreateIndex
CREATE INDEX "threat_scans_userId_createdAt_idx" ON "threat_scans"("userId", "createdAt" DESC);

-- CreateIndex
CREATE INDEX "threat_scans_scanType_status_idx" ON "threat_scans"("scanType", "status");

-- CreateIndex
CREATE UNIQUE INDEX "threat_analyses_scanId_key" ON "threat_analyses"("scanId");

-- CreateIndex
CREATE INDEX "threat_analyses_riskLevel_idx" ON "threat_analyses"("riskLevel");

-- CreateIndex
CREATE INDEX "threat_indicators_analysisId_idx" ON "threat_indicators"("analysisId");

-- CreateIndex
CREATE UNIQUE INDEX "risk_scores_analysisId_key" ON "risk_scores"("analysisId");

-- CreateIndex
CREATE UNIQUE INDEX "saved_websites_analysisId_key" ON "saved_websites"("analysisId");

-- CreateIndex
CREATE INDEX "saved_websites_domain_idx" ON "saved_websites"("domain");

-- CreateIndex
CREATE UNIQUE INDEX "threat_reports_reportNumber_key" ON "threat_reports"("reportNumber");

-- CreateIndex
CREATE INDEX "threat_reports_userId_createdAt_idx" ON "threat_reports"("userId", "createdAt" DESC);

-- CreateIndex
CREATE INDEX "threat_reports_status_priority_idx" ON "threat_reports"("status", "priority");

-- CreateIndex
CREATE INDEX "threat_reports_reportNumber_idx" ON "threat_reports"("reportNumber");

-- CreateIndex
CREATE INDEX "notifications_userId_isRead_createdAt_idx" ON "notifications"("userId", "isRead", "createdAt" DESC);

-- CreateIndex
CREATE UNIQUE INDEX "investigations_caseId_key" ON "investigations"("caseId");

-- CreateIndex
CREATE UNIQUE INDEX "investigations_reportId_key" ON "investigations"("reportId");

-- CreateIndex
CREATE INDEX "investigations_status_city_idx" ON "investigations"("status", "city");

-- CreateIndex
CREATE INDEX "investigations_assignedTo_idx" ON "investigations"("assignedTo");

-- CreateIndex
CREATE UNIQUE INDEX "incidents_incidentId_key" ON "incidents"("incidentId");

-- CreateIndex
CREATE INDEX "incidents_status_priority_idx" ON "incidents"("status", "priority");

-- CreateIndex
CREATE INDEX "incidents_assignedTo_idx" ON "incidents"("assignedTo");

-- CreateIndex
CREATE INDEX "incidents_createdBy_idx" ON "incidents"("createdBy");

-- CreateIndex
CREATE INDEX "incident_events_incidentId_createdAt_idx" ON "incident_events"("incidentId", "createdAt");

-- CreateIndex
CREATE INDEX "evidence_type_value_idx" ON "evidence"("type", "value");

-- CreateIndex
CREATE INDEX "evidence_investigationId_idx" ON "evidence"("investigationId");

-- CreateIndex
CREATE INDEX "timeline_events_actorId_createdAt_idx" ON "timeline_events"("actorId", "createdAt" DESC);

-- CreateIndex
CREATE INDEX "timeline_events_type_createdAt_idx" ON "timeline_events"("type", "createdAt" DESC);

-- CreateIndex
CREATE INDEX "audit_logs_userId_createdAt_idx" ON "audit_logs"("userId", "createdAt" DESC);

-- CreateIndex
CREATE INDEX "audit_logs_entity_entityId_idx" ON "audit_logs"("entity", "entityId");

-- CreateIndex
CREATE UNIQUE INDEX "system_settings_key_key" ON "system_settings"("key");

-- CreateIndex
CREATE INDEX "evidence_uploads_userId_createdAt_idx" ON "evidence_uploads"("userId", "createdAt" DESC);

-- CreateIndex
CREATE UNIQUE INDEX "evidence_uploads_userId_fileHash_key" ON "evidence_uploads"("userId", "fileHash");

-- CreateIndex
CREATE INDEX "graph_nodes_entityType_idx" ON "graph_nodes"("entityType");

-- CreateIndex
CREATE INDEX "graph_nodes_normalizedVal_idx" ON "graph_nodes"("normalizedVal");

-- CreateIndex
CREATE UNIQUE INDEX "graph_nodes_entityType_normalizedVal_key" ON "graph_nodes"("entityType", "normalizedVal");

-- CreateIndex
CREATE INDEX "graph_edges_fromNodeId_idx" ON "graph_edges"("fromNodeId");

-- CreateIndex
CREATE INDEX "graph_edges_toNodeId_idx" ON "graph_edges"("toNodeId");

-- CreateIndex
CREATE INDEX "graph_edges_scanId_idx" ON "graph_edges"("scanId");

-- CreateIndex
CREATE INDEX "scammer_profiles_phones_idx" ON "scammer_profiles"("phones");

-- CreateIndex
CREATE INDEX "scammer_profiles_emails_idx" ON "scammer_profiles"("emails");

-- CreateIndex
CREATE INDEX "scammer_profiles_upiIds_idx" ON "scammer_profiles"("upiIds");

-- CreateIndex
CREATE INDEX "conversations_userId_updatedAt_idx" ON "conversations"("userId", "updatedAt" DESC);

-- CreateIndex
CREATE INDEX "messages_conversationId_createdAt_idx" ON "messages"("conversationId", "createdAt");

-- CreateIndex
CREATE UNIQUE INDEX "upi_reputations_upiId_key" ON "upi_reputations"("upiId");

-- CreateIndex
CREATE INDEX "upi_reputations_normalizedUpi_idx" ON "upi_reputations"("normalizedUpi");

-- CreateIndex
CREATE UNIQUE INDEX "ip_history_ip_key" ON "ip_history"("ip");

-- CreateIndex
CREATE UNIQUE INDEX "suspicious_infrastructure_ip_key" ON "suspicious_infrastructure"("ip");

-- CreateIndex
CREATE INDEX "suspicious_infrastructure_country_idx" ON "suspicious_infrastructure"("country");

-- CreateIndex
CREATE INDEX "suspicious_infrastructure_riskLevel_idx" ON "suspicious_infrastructure"("riskLevel");

-- AddForeignKey
ALTER TABLE "profiles" ADD CONSTRAINT "profiles_userId_fkey" FOREIGN KEY ("userId") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "sessions" ADD CONSTRAINT "sessions_userId_fkey" FOREIGN KEY ("userId") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "threat_scans" ADD CONSTRAINT "threat_scans_userId_fkey" FOREIGN KEY ("userId") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "threat_analyses" ADD CONSTRAINT "threat_analyses_scanId_fkey" FOREIGN KEY ("scanId") REFERENCES "threat_scans"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "threat_indicators" ADD CONSTRAINT "threat_indicators_analysisId_fkey" FOREIGN KEY ("analysisId") REFERENCES "threat_analyses"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "risk_scores" ADD CONSTRAINT "risk_scores_analysisId_fkey" FOREIGN KEY ("analysisId") REFERENCES "threat_analyses"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "saved_websites" ADD CONSTRAINT "saved_websites_analysisId_fkey" FOREIGN KEY ("analysisId") REFERENCES "threat_analyses"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "threat_reports" ADD CONSTRAINT "threat_reports_userId_fkey" FOREIGN KEY ("userId") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "notifications" ADD CONSTRAINT "notifications_userId_fkey" FOREIGN KEY ("userId") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "investigations" ADD CONSTRAINT "investigations_assignedTo_fkey" FOREIGN KEY ("assignedTo") REFERENCES "users"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "investigations" ADD CONSTRAINT "investigations_networkId_fkey" FOREIGN KEY ("networkId") REFERENCES "fraud_networks"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "investigations" ADD CONSTRAINT "investigations_reportId_fkey" FOREIGN KEY ("reportId") REFERENCES "threat_reports"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "incidents" ADD CONSTRAINT "incidents_assignedTo_fkey" FOREIGN KEY ("assignedTo") REFERENCES "users"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "incidents" ADD CONSTRAINT "incidents_createdBy_fkey" FOREIGN KEY ("createdBy") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "incident_events" ADD CONSTRAINT "incident_events_incidentId_fkey" FOREIGN KEY ("incidentId") REFERENCES "incidents"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "evidence" ADD CONSTRAINT "evidence_investigationId_fkey" FOREIGN KEY ("investigationId") REFERENCES "investigations"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "evidence" ADD CONSTRAINT "evidence_networkId_fkey" FOREIGN KEY ("networkId") REFERENCES "fraud_networks"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "audit_logs" ADD CONSTRAINT "audit_logs_userId_fkey" FOREIGN KEY ("userId") REFERENCES "users"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "evidence_uploads" ADD CONSTRAINT "evidence_uploads_reportId_fkey" FOREIGN KEY ("reportId") REFERENCES "threat_reports"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "evidence_uploads" ADD CONSTRAINT "evidence_uploads_userId_fkey" FOREIGN KEY ("userId") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "graph_edges" ADD CONSTRAINT "graph_edges_fromNodeId_fkey" FOREIGN KEY ("fromNodeId") REFERENCES "graph_nodes"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "graph_edges" ADD CONSTRAINT "graph_edges_toNodeId_fkey" FOREIGN KEY ("toNodeId") REFERENCES "graph_nodes"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "conversations" ADD CONSTRAINT "conversations_userId_fkey" FOREIGN KEY ("userId") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "messages" ADD CONSTRAINT "messages_conversationId_fkey" FOREIGN KEY ("conversationId") REFERENCES "conversations"("id") ON DELETE CASCADE ON UPDATE CASCADE;
