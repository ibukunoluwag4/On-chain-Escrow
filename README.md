📖 README – P2P Freelancing Escrow Contract

Overview

This smart contract implements a milestone-based escrow system for P2P freelancing agreements on the Stacks blockchain. It ensures secure handling of funds between clients and freelancers by holding payments in escrow until project milestones are completed and approved.

✨ Features

Escrow Creation: Clients can create an escrow by funding it with STX and defining a milestone description.

Milestone Submission: Freelancers submit milestone deliverables (data/details) for client review.

Payment Release: Clients can approve the milestone, releasing escrow funds to the freelancer.

Dispute Resolution: Contract owner has authority to perform emergency releases in case of disputes.

Immutable Tracking: Each escrow includes metadata like creation block height, milestone description, and submission details.

⚖️ Error Codes

u100 → Not authorized

u101 → Escrow not found

u102 → Invalid amount

u103 → Milestone not submitted

u104 → Already released

u105 → Insufficient funds

📂 Data Model

Each escrow stores:

client: Principal who creates and funds the escrow

freelancer: Principal assigned to complete the milestone

amount: STX locked in escrow

milestone-description: Description of agreed deliverables

milestone-submitted: Status flag (true/false)

milestone-data: Data/details submitted by freelancer

released: Status flag (true/false)

created-at: Block height of creation

🔑 Public Functions

create-escrow(freelancer, amount, milestone-description) → Creates a new escrow and locks STX.

submit-milestone(escrow-id, milestone-data) → Freelancer submits milestone deliverable.

verify-and-release(escrow-id) → Client verifies and releases escrowed STX to freelancer.

emergency-release(escrow-id, release-to) → Contract owner resolves disputes by releasing escrow to a chosen principal.

📖 Read-Only Functions

get-escrow(escrow-id) → Fetch details of a specific escrow.

get-escrow-counter() → Get the latest escrow ID counter.

✅ Usage Flow

Client creates escrow with milestone description and funding.

Freelancer submits milestone deliverables.

Client verifies deliverables and releases payment.

If disputes arise, contract owner intervenes with emergency release.