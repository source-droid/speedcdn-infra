// SpeedyCDN Test JavaScript - Student: s23150618
console.log('SpeedyCDN Test Script Loaded');

function showStudentID() {
    return 's23150618';
}

document.addEventListener('DOMContentLoaded', function() {
    const div = document.createElement('div');
    div.className = 'student-badge';
    div.innerHTML = 'Student ID: s23150618';
    div.style.cssText = 'position: fixed; bottom: 10px; right: 10px; background: #333; color: white; padding: 5px 10px; border-radius: 5px; font-size: 12px; z-index: 9999;';
    document.body.appendChild(div);
});
