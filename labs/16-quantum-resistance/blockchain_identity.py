#!/usr/bin/env python3
"""
Lesson 16: Blockchain-Based Identity Verification
Decentralized identity management for Zero Trust
"""

import hashlib
import json
import time
from datetime import datetime, timezone
import secrets

class Block:
    """Basic blockchain block for identity management"""
    
    def __init__(self, index, timestamp, data, previous_hash):
        self.index = index
        self.timestamp = timestamp
        self.data = data  # Identity transactions
        self.previous_hash = previous_hash
        self.nonce = 0  # Add nonce for mining
        self.hash = self.calculate_hash()
        
    def calculate_hash(self):
        """Calculate block hash"""
        block_string = json.dumps({
            "index": self.index,
            "timestamp": self.timestamp,
            "data": self.data,
            "previous_hash": self.previous_hash,  # FIXED: was self.public_key
            "nonce": self.nonce
        }, sort_keys=True)
        return hashlib.sha256(block_string.encode()).hexdigest()

class IdentityBlockchain:
    """Blockchain for decentralized identity management"""
    
    def __init__(self):
        self.chain = [self.create_genesis_block()]
        self.pending_identities = []
        self.difficulty = 2
        
    def create_genesis_block(self):
        """Create the first block in the chain"""
        return Block(0, datetime.now(timezone.utc).isoformat(), 
                    {"type": "GENESIS", "message": "Zero Trust Identity Chain"}, "0")
    
    def get_latest_block(self):
        """Get the most recent block"""
        return self.chain[-1]
    
    def add_identity_transaction(self, user_id, public_key_hash, action="REGISTER"):
        """Add identity transaction to pending pool"""
        transaction = {
            "user_id": user_id,
            "public_key_hash": public_key_hash,
            "action": action,  # REGISTER, VERIFY, REVOKE
            "timestamp": datetime.now(timezone.utc).isoformat(),
            "transaction_id": secrets.token_hex(16)
        }
        
        self.pending_identities.append(transaction)
        return transaction["transaction_id"]
    
    def mine_pending_identities(self):
        """Mine pending identity transactions into a new block"""
        if not self.pending_identities:
            return False
            
        block = Block(
            len(self.chain),
            datetime.now(timezone.utc).isoformat(),
            self.pending_identities,
            self.get_latest_block().hash
        )
        
        # Simple proof-of-work
        while block.hash[:self.difficulty] != "0" * self.difficulty:
            block.nonce += 1
            block.hash = block.calculate_hash()
        
        self.chain.append(block)
        self.pending_identities = []
        return True
    
    def verify_identity(self, user_id, public_key_hash):
        """Verify identity exists and is valid in blockchain"""
        for block in self.chain[1:]:  # Skip genesis block
            for transaction in block.data:
                if (transaction["user_id"] == user_id and 
                    transaction["public_key_hash"] == public_key_hash and
                    transaction["action"] in ["REGISTER", "VERIFY"]):
                    return True
        return False
    
    def get_identity_history(self, user_id):
        """Get complete identity history for a user"""
        history = []
        for block in self.chain[1:]:
            for transaction in block.data:
                if transaction["user_id"] == user_id:
                    history.append(transaction)
        return history
    
    def is_chain_valid(self):
        """Validate the entire blockchain"""
        for i in range(1, len(self.chain)):
            current_block = self.chain[i]
            previous_block = self.chain[i-1]
            
            if current_block.hash != current_block.calculate_hash():
                return False
            if current_block.previous_hash != previous_block.hash:
                return False
                
        return True

class DecentralizedIdentityManager:
    """Manager for decentralized Zero Trust identities"""
    
    def __init__(self):
        self.blockchain = IdentityBlockchain()
        self.identities = {}
        
    def register_identity(self, user_id, quantum_identity):
        """Register quantum-resistant identity on blockchain"""
        transaction_id = self.blockchain.add_identity_transaction(
            user_id, quantum_identity.identity_hash, "REGISTER"
        )
        
        # Mine the transaction
        self.blockchain.mine_pending_identities()
        
        # Store locally for quick access
        self.identities[user_id] = {
            'quantum_identity': quantum_identity,
            'blockchain_verified': True,
            'registration_time': datetime.now(timezone.utc).isoformat()
        }
        
        return transaction_id
    
    def verify_access_request(self, user_id, message, signature):
        """Verify access request using blockchain identity"""
        # Check if identity exists and is verified
        if user_id not in self.identities:
            return {"allowed": False, "reason": "Identity not registered"}
        
        identity = self.identities[user_id]
        quantum_identity = identity['quantum_identity']
        
        # Verify quantum signature
        signature_valid = quantum_identity.verify_signature(message, signature)
        if not signature_valid:
            return {"allowed": False, "reason": "Invalid quantum signature"}
        
        # Verify on blockchain
        blockchain_verified = self.blockchain.verify_identity(
            user_id, quantum_identity.identity_hash
        )
        
        if not blockchain_verified:
            return {"allowed": False, "reason": "Blockchain verification failed"}
        
        return {
            "allowed": True,
            "reason": "Quantum and blockchain verification successful",
            "user_id": user_id,
            "quantum_secure": True,
            "blockchain_verified": True,
            "trust_score": 95  # High trust from dual verification
        }
    
    def revoke_identity(self, user_id):
        """Revoke identity on blockchain"""
        if user_id in self.identities:
            quantum_identity = self.identities[user_id]['quantum_identity']
            transaction_id = self.blockchain.add_identity_transaction(
                user_id, quantum_identity.identity_hash, "REVOKE"
            )
            self.blockchain.mine_pending_identities()
            del self.identities[user_id]
            return transaction_id
        return None

def demonstrate_blockchain_identity():
    """Demonstrate blockchain-based identity verification"""
    print("BLOCKCHAIN IDENTITY VERIFICATION DEMONSTRATION")
    print("=" * 55)
    
    # Import QuantumResistantIdentity from previous module
    from quantum_auth import QuantumResistantIdentity
    
    # Create decentralized identity manager
    print("1. Initializing decentralized identity manager...")
    id_manager = DecentralizedIdentityManager()
    
    # Register identities
    print("\n2. Registering quantum-resistant identities on blockchain...")
    users = []
    for i in range(3):
        user = QuantumResistantIdentity(f"quantum_user_{i+1}")
        transaction_id = id_manager.register_identity(user.user_id, user)
        users.append(user)
        print(f"   Registered: {user.user_id}")
        print(f"   Transaction: {transaction_id}")
        print(f"   Identity Hash: {user.identity_hash[:16]}...")
    
    # Verify blockchain integrity
    print("\n3. Verifying blockchain integrity...")
    is_valid = id_manager.blockchain.is_chain_valid()
    print(f"   Blockchain valid: {is_valid}")
    print(f"   Chain length: {len(id_manager.blockchain.chain)} blocks")
    
    # Test access verification
    print("\n4. Testing access verification...")
    test_user = users[0]
    message = "Access request to quantum-secure financial system"
    signature = test_user.quantum_sign(message)
    
    verification = id_manager.verify_access_request(test_user.user_id, message, signature)
    print(f"   Access request: {message}")
    print(f"   Verification result: {verification}")
    
    # Test identity revocation
    print("\n5. Testing identity revocation...")
    user_to_revoke = users[1]
    revocation_id = id_manager.revoke_identity(user_to_revoke.user_id)
    print(f"   Revoked: {user_to_revoke.user_id}")
    print(f"   Revocation transaction: {revocation_id}")
    
    # Try to verify revoked identity
    revoked_verification = id_manager.verify_access_request(
        user_to_revoke.user_id, message, signature
    )
    print(f"   Revoked identity access: {revoked_verification['allowed']}")

if __name__ == "__main__":
    demonstrate_blockchain_identity()
