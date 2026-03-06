package com.example.devnote.data

import androidx.room.Entity
import androidx.room.PrimaryKey

@Entity(tableName = "projects")
data class Project(
    @PrimaryKey val id: String = java.util.UUID.randomUUID().toString(),
    val name: String,
    val createdAt: Long = System.currentTimeMillis(),
    val isGithubRepo: Boolean = false,
    val githubFullName: String? = null,
    val githubUrl: String? = null,
    val githubDescription: String? = null,
    val githubLanguage: String? = null
)
