package com.example.devnote.data

import androidx.lifecycle.LiveData
import androidx.room.Dao
import androidx.room.Insert
import androidx.room.Query

data class NoteWithProject(
    val id: String,
    val content: String,
    val priority: NotePriority,
    val category: NoteCategory,
    val projectName: String
)

@Dao
interface NoteDao {
    @Insert
    fun insert(note: Note): Long

    @Query("""
        SELECT n.id, n.content, n.priority, n.category, p.name as projectName 
        FROM notes n 
        INNER JOIN projects p ON n.projectId = p.id 
        ORDER BY n.id DESC
    """)
    fun getNotesWithProjectNames(): LiveData<List<NoteWithProject>>

    @Query("SELECT * FROM notes WHERE projectId = :projectId")
    fun getNotesByProject(projectId: String): LiveData<List<Note>>
}
