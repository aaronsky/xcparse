public enum IOError: Error {
    case invalidFilePath(String)
    case missingPIFCacheDirectories
}
