package com.example.devnote.data

import androidx.room.Entity
import androidx.room.ForeignKey
import androidx.room.PrimaryKey
import androidx.room.Index

enum class NoteCategory(val label: String, val color: String) {
    BUG_FIX("Hata Düzeltme", "red"),
    NEW_FEATURE("Yeni Özellik", "green")
}

enum class NotePriority(val label: String) {
    LOW("Düşük"),
    MEDIUM("Orta"),
    HIGH("Yüksek")
}

@Entity(
    tableName = "notes",
    foreignKeys = [
        ForeignKey(
            entity = Project::class,
            parentColumns = ["id"],
            childColumns = ["projectId"],
            onDelete = ForeignKey.CASCADE
        )
    ],
    indices = [Index("projectId")]
)
data class Note(
    @PrimaryKey val id: String = java.util.UUID.randomUUID().toString(),
    val projectId: String,
    val content: String,
    val category: NoteCategory,
    val priority: NotePriority,
    val createdAt: Long = System.currentTimeMillis()
)
