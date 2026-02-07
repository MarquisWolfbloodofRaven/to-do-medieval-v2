// Esperar DOM carregar
document.addEventListener('DOMContentLoaded', () => {
    const addTaskForm = document.getElementById('addTaskForm');
    const taskList = document.getElementById('taskList');
    const timerDisplay = document.getElementById('timerDisplay');
    const hourglass = document.querySelector('.hourglass');
    const sandSound = document.getElementById('sandSound'); // Opcional

    let tasks = JSON.parse(localStorage.getItem('tasks')) || []; // Carregar tarefas do localStorage
    let currentTimer = null; // Timer atual
    let elapsedTime = 0; // Tempo decorrido em segundos
    let activeTaskId = null; // ID da tarefa ativa

    // Função para renderizar tarefas
    function renderTasks() {
        taskList.innerHTML = ''; // Limpar lista
        tasks.forEach((task, index) => {
            const li = document.createElement('li');
            li.classList.add('task-item');
            li.setAttribute('aria-label', `Codex: ${task.title}`);
            if (task.completed) li.classList.add('completed');

            // Título e checkbox
            const title = document.createElement('h3');
            title.textContent = task.title;
            const checkbox = document.createElement('input');
            checkbox.type = 'checkbox';
            checkbox.checked = task.completed;
            checkbox.addEventListener('change', () => toggleComplete(index));
            checkbox.setAttribute('aria-label', `Marcar ${task.title} como concluída`);

            // Detalhes (expandidos ao clicar)
            const details = document.createElement('div');
            details.classList.add('task-details');
            details.innerHTML = `<p>${task.description}</p>`;

            // Botões
            const buttons = document.createElement('div');
            buttons.classList.add('task-buttons');
            const editBtn = document.createElement('button');
            editBtn.textContent = 'Editar';
            editBtn.addEventListener('click', (e) => { e.stopPropagation(); editTask(index); });
            const deleteBtn = document.createElement('button');
            deleteBtn.textContent = 'Remover';
            deleteBtn.addEventListener('click', (e) => { e.stopPropagation(); deleteTask(index); });
            const startBtn = document.createElement('button');
            startBtn.textContent = 'Iniciar Timer';
            startBtn.addEventListener('click', (e) => { e.stopPropagation(); startTimer(index); });
            const pauseBtn = document.createElement('button');
            pauseBtn.textContent = 'Pausar';
            pauseBtn.addEventListener('click', (e) => { e.stopPropagation(); pauseTimer(); });
            const resetBtn = document.createElement('button');
            resetBtn.textContent = 'Resetar';
            resetBtn.addEventListener('click', (e) => { e.stopPropagation(); resetTimer(); });
            buttons.append(editBtn, deleteBtn, startBtn, pauseBtn, resetBtn);

            details.appendChild(buttons);

            // Clique para expandir
            li.addEventListener('click', () => {
                li.classList.toggle('open');
            });

            li.append(title, checkbox, details);
            taskList.appendChild(li);
        });
        saveTasks(); // Salvar após render
    }

    // Adicionar tarefa
    addTaskForm.addEventListener('submit', (e) => {
        e.preventDefault();
        const title = document.getElementById('taskTitle').value;
        const description = document.getElementById('taskDescription').value;
        tasks.push({ title, description, completed: false, time: 0 });
        renderTasks();
        addTaskForm.reset();
    });

    // Editar tarefa
    function editTask(index) {
        const newTitle = prompt('Novo título:', tasks[index].title);
        const newDesc = prompt('Nova descrição:', tasks[index].description);
        if (newTitle && newDesc) {
            tasks[index].title = newTitle;
            tasks[index].description = newDesc;
            renderTasks();
        }
    }

    // Deletar tarefa
    function deleteTask(index) {
        if (confirm('Remover este codex?')) {
            tasks.splice(index, 1);
            if (activeTaskId === index) resetTimer(); // Resetar se ativo
            renderTasks();
        }
    }

    // Marcar como concluída
    function toggleComplete(index) {
        tasks[index].completed = !tasks[index].completed;
        renderTasks();
    }

    // Iniciar timer
    function startTimer(index) {
        if (currentTimer) pauseTimer(); // Pausar anterior
        activeTaskId = index;
        elapsedTime = tasks[index].time || 0; // Carregar tempo salvo
        hourglass.classList.add('running');
        sandSound.play(); // Opcional
        currentTimer = setInterval(() => {
            elapsedTime++;
            tasks[index].time = elapsedTime; // Salvar tempo
            updateTimerDisplay();
            saveTasks();
        }, 1000);
    }

    // Pausar timer
    function pauseTimer() {
        clearInterval(currentTimer);
        currentTimer = null;
        hourglass.classList.remove('running');
        sandSound.pause(); // Opcional
    }

    // Resetar timer
    function resetTimer() {
        pauseTimer();
        elapsedTime = 0;
        if (activeTaskId !== null) {
            tasks[activeTaskId].time = 0;
            activeTaskId = null;
        }
        updateTimerDisplay();
        saveTasks();
    }

    // Atualizar display do timer
    function updateTimerDisplay() {
        const minutes = Math.floor(elapsedTime / 60).toString().padStart(2, '0');
        const seconds = (elapsedTime % 60).toString().padStart(2, '0');
        timerDisplay.textContent = `${minutes}:${seconds}`;
    }

    // Salvar tarefas no localStorage
    function saveTasks() {
        localStorage.setItem('tasks', JSON.stringify(tasks));
    }

    // Inicial render
    renderTasks();
    updateTimerDisplay();
});
