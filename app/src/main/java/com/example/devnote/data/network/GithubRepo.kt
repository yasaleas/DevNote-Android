package com.example.devnote.data.network

import com.google.gson.annotations.SerializedName

data class GithubRepo(
    @SerializedName("id") val id: Long,
    @SerializedName("name") val name: String,
    @SerializedName("full_name") val fullName: String?,
    @SerializedName("description") val description: String?,
    @SerializedName("language") val language: String?,
    @SerializedName("html_url") val htmlUrl: String?,
    @SerializedName("created_at") val createdAt: String?
)
