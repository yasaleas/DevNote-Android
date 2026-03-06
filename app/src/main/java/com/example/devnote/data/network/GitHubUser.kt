package com.example.devnote.data.network

import com.google.gson.annotations.SerializedName

data class GitHubUser(
    @SerializedName("login") val login: String,
    @SerializedName("avatar_url") val avatarUrl: String?,
    @SerializedName("public_repos") val publicRepos: Int?
)
