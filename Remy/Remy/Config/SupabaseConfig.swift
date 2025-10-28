//
//  SupabaseConfig.swift
//  Remy
//
//  Created by Claude Code on 10/18/25.
//

import Foundation

/// Supabase configuration and credentials
struct SupabaseConfig {
    // MARK: - Credentials

    /// Supabase project URL
    static var projectURL: String {
        guard let url = Bundle.main.object(forInfoDictionaryKey: "SUPABASE_URL") as? String,
              !url.isEmpty,
              !url.hasPrefix("$(") else {
            print("""
                [SupabaseConfig] WARNING: Supabase URL not configured properly.
                Using placeholder value. App functionality may be limited.

                Setup Instructions:
                1. Ensure Config.xcconfig exists in Remy/Config/
                2. Add: SUPABASE_URL = https://your-project.supabase.co
                3. Rebuild the project
                """)
            return "https://placeholder.supabase.co"
        }

        guard url.hasPrefix("https://") else {
            print("[SupabaseConfig] WARNING: Supabase URL must use HTTPS. Using URL as-is.")
            return url
        }

        return url
    }

    /// Supabase anonymous (public) API key
    /// This key is safe to use in client-side applications
    static var anonKey: String {
        guard let key = Bundle.main.object(forInfoDictionaryKey: "SUPABASE_ANON_KEY") as? String,
              !key.isEmpty,
              !key.hasPrefix("$(") else {
            print("""
                [SupabaseConfig] WARNING: Supabase anon key not configured properly.
                Using placeholder value. App functionality may be limited.

                Setup Instructions:
                1. Ensure Config.xcconfig exists in Remy/Config/
                2. Add: SUPABASE_ANON_KEY = your-anon-key-here
                3. Rebuild the project
                """)
            return "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJwbGFjZWhvbGRlciJ9.placeholder"
        }

        // Basic validation - Supabase JWT tokens start with "eyJ"
        guard key.hasPrefix("eyJ") else {
            print("[SupabaseConfig] WARNING: Invalid Supabase anon key format. Using key as-is.")
            return key
        }

        return key
    }

    // MARK: - Storage Buckets

    static let photoBucketName = "journal-photos"

    // MARK: - Validation

    static func validate() throws {
        guard !projectURL.isEmpty else {
            throw SupabaseConfigError.missingProjectURL
        }

        guard !anonKey.isEmpty else {
            throw SupabaseConfigError.missingAnonKey
        }

        guard URL(string: projectURL) != nil else {
            throw SupabaseConfigError.invalidProjectURL
        }
    }
}

// MARK: - Configuration Errors

enum SupabaseConfigError: LocalizedError {
    case missingProjectURL
    case missingAnonKey
    case invalidProjectURL

    var errorDescription: String? {
        switch self {
        case .missingProjectURL:
            return "Supabase project URL is missing"
        case .missingAnonKey:
            return "Supabase anon key is missing"
        case .invalidProjectURL:
            return "Supabase project URL is invalid"
        }
    }
}
