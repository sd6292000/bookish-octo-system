
# Original 13 User Stories + AC + Effort
## US1: Investigate current backend certificate management workflow
**User Story**
As an EH Gateway Team member,
I want to investigate the existing backend certificate management process,
so that we can prepare clear technical specifications and integration foundations for future certificate feature development.

**Acceptance Criteria**
1. Complete investigation document for current backend certificate workflow
2. Clarify existing limitation and integration gap
3. Output clear technical suggestion for subsequent development

**Effort Estimate**: 2 MD

---

## US2: Support dynamic Trusted KeyStore loading for backend TLS
**User Story**
As an EH Gateway Developer,
I want to support dynamically adding and updating backend trusted KeyStores at runtime,
so that TLS trust configuration for backend routes can be adjusted flexibly without gateway restart.

**Acceptance Criteria**
1. Gateway supports hot loading of new Trusted KeyStore without restart
2. Updated KeyStore takes effect for new incoming requests immediately
3. Invalid KeyStore file will trigger error log and fail-safe protection

**Effort Estimate**: 4 MD

---

## US3: Expose API to query all trusted certificates in route engine
**User Story**
As an EH Gateway Developer,
I want to provide a unified API in the Route Setting Engine to list all loaded trusted certificates,
so that the admin system can retrieve and display certificate information for centralized management.

**Acceptance Criteria**
1. Rest API is provided to query all effective trusted certificates
2. API returns certificate basic info: hash, expire time, CMDB ID
3. API supports normal permission control

**Effort Estimate**: 1.5 MD

---

## US4: Add certificate hash field in backend route configuration
**User Story**
As an EH Gateway Developer,
I want to extend the backend route model with certificate hash fields,
so that the gateway can support certificate-hash-based matching and advanced route policy control.

**Acceptance Criteria**
1. Route database model added certificate hash field
2. Route configuration supports persist and load certificate hash value
3. Field can be displayed and edited in admin backend model

**Effort Estimate**: 1.5 MD

---

## US5: Build certificate upload & lifecycle management page in Admin
**User Story**
As an EH App Admin Developer,
I want to implement a certificate management page that supports certificate uploading, CMDB ID binding, public/private certificate classification, and persistent storage of SHA-256 fingerprint and expiry time,
so that administrators can fully manage the entire certificate lifecycle with clear ownership and security auditing.

**Acceptance Criteria**
1. Frontend page supports certificate file upload
2. Support bind CMDB ID and distinguish public/private certificate
3. System auto calculate & store SHA-256 hash and expire time
4. Page displays full certificate list with basic attributes

**Effort Estimate**: 5 MD

---

## US6: Create new database table for certificate Keystore repository
**User Story**
As an EH App Admin Backend Developer,
I want to design and create a new database table for certificate Keystore management,
so that all uploaded certificate trust materials can be structurally and persistently stored.

**Acceptance Criteria**
1. New database table created with complete certificate fields
2. Database supports normal CRUD for certificate data
3. Data integrity and unique constraint configured

**Effort Estimate**: 1 MD

---

## US7: Auto create backend shortcut while uploading new certificates
**User Story**
As an EH App Admin Backend Developer,
I want the system to automatically add corresponding backend shortcuts when new certificates are uploaded (ADD-only operation),
so that certificate and route backend associations can be established automatically to reduce manual operation.

**Acceptance Criteria**
1. System auto-generates backend shortcut after new certificate upload
2. Only ADD operation is supported, no update/delete shortcut logic
3. Association relationship can be queried in database

**Effort Estimate**: 2 MD

---

## US8: Research and design advanced backend routing strategies
**User Story**
As an EH Gateway Technical Researcher,
I want to investigate and define gateway implementation solutions for advanced routing capabilities including session stickiness, latency-based routing, and customizable health check policies,
so that the gateway can support enterprise-level complex traffic control scenarios.

**Acceptance Criteria**
1. Output research document for all advanced routing strategies
2. Confirm SCG technical implementation solution & limitation
3. Provide feasible development roadmap

**Effort Estimate**: 5 MD

---

## US9: Support dynamic health check for multi-backend single instance
**User Story**
As an EH Gateway Developer,
I want to research and implement dynamic health check logic for single instances hosting multiple backend services,
so that unhealthy sub-backends can be accurately detected and isolated without affecting other healthy services on the same instance.

**Acceptance Criteria**
1. Gateway supports independent health check for multiple backends under one instance
2. Unhealthy backend will be isolated automatically
3. Healthy backends on same instance remain normal serving

**Effort Estimate**: 4 MD

---

## US10: Implement IP-based and condition-based backend sticky routing
**User Story**
As an EH Gateway Developer,
I want to implement client IP-based and custom condition-based session sticky routing,
so that user requests can be consistently routed to the same backend instance to maintain session continuity.

**Acceptance Criteria**
1. Support client IP hash sticky routing
2. Support custom request condition sticky routing
3. Sticky policy takes effect dynamically by route config

**Effort Estimate**: 4 MD

---

## US11: Support weight-based load balancing and canary routing
**User Story**
As an EH Gateway Developer,
I want to implement weight-based traffic splitting and canary deployment routing rules,
so that the system supports flexible traffic gray release, A/B testing, and balanced load distribution.

**Acceptance Criteria**
1. Backend route supports weight ratio configuration
2. Traffic canary splitting works as configured
3. Weight & canary rule can be dynamically updated

**Effort Estimate**: 4 MD

---

## US12: Investigate backend retry mechanism specifications
**User Story**
As an EH Gateway Developer,
I want to investigate configurable backend retry strategies including retry count and backoff policy,
so that transient network or backend errors can be automatically recovered to improve system stability.

**Acceptance Criteria**
1. Complete retry mechanism investigation report
2. Confirm supported error code & retry backoff strategy
3. Define configurable parameters for future development

**Effort Estimate**: 2 MD

---

## US13: Evaluate feasibility and impact of enabling HTTP/2
**User Story**
As an EH Gateway Technical Architect,
I want to analyze the compatibility, performance improvement and potential risk of enabling HTTP/2 protocol,
so that the team can make accurate technical decisions for protocol upgrade planning.

**Acceptance Criteria**
1. Output HTTP/2 enablement evaluation report
2. Clarify performance gain, compatibility risk and migration cost
3. Provide final enablement suggestion

**Effort Estimate**: 2 MD

---

# Supplemental Missing User Stories (Necessary & High Priority)
## US14: Certificate expiration reminder & basic audit log
**User Story**
As an EH Admin User,
I want the system to record certificate operation logs and support expiration reminder check,
so that we can avoid certificate expiration outage and trace certificate management behavior.

**AC**
1. Log all certificate upload/update/delete operations
2. Support query certificate expiration status
3. Provide basic expiration pending warning

**Effort**: 2 MD

---

## US15: Dynamic health check parameter configurable via admin
**User Story**
As an EH App Admin User,
I want to configure health check interval, timeout and failure threshold via admin page,
so that different backend services can match customized health check strategies.

**AC**
1. Admin page supports health check parameter configuration
2. Parameters take effect dynamically on gateway
3. Invalid parameter input has verification protection

**Effort**: 3 MD

---

## US16: Persist & load advanced routing strategy configuration
**User Story**
As an EH Gateway Developer,
I want to persist all advanced routing policies (sticky/weight/canary) in database and load dynamically,
so that complex routing rules can be managed uniformly via admin system.

**AC**
1. All advanced routing config saved to DB
2. Gateway hot loads routing policy without restart
3. Config modification takes effect in real time

**Effort**: 3 MD

---

## US17: Basic error handling & fallback for certificate abnormal scenario
**User Story**
As an EH Gateway Developer,
I want to add global exception handling for invalid/expired/abnormal backend certificates,
so that gateway can reject illegal TLS connection and output clear error logs.

**AC**
1. Expired/invalid certificate triggers connection reject
2. Clear error log printed for troubleshooting
3. No gateway crash under abnormal certificate scenario

**Effort**: 2 MD

