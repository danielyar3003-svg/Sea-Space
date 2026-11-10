"""Symmetric field encryption for secrets stored in the database (e.g. Gmail refresh tokens)."""

from cryptography.fernet import Fernet, InvalidToken

from app.core.config import Settings


class EncryptionNotConfigured(RuntimeError):
    pass


def _fernet(settings: Settings) -> Fernet:
    if settings.token_encryption_key is None:
        raise EncryptionNotConfigured("TOKEN_ENCRYPTION_KEY is not set")
    return Fernet(settings.token_encryption_key.get_secret_value().encode())


def encrypt(value: str, settings: Settings) -> bytes:
    return _fernet(settings).encrypt(value.encode())


def decrypt(token: bytes, settings: Settings) -> str:
    try:
        return _fernet(settings).decrypt(token).decode()
    except InvalidToken as exc:
        raise ValueError("Encrypted value cannot be decrypted with the current key") from exc
