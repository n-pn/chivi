export let book_status = ['Còn tiếp', 'Hoàn thành', 'Thái giám', 'Không rõ']
export const map_status = (status = 0) => book_status[status] || 'Không rõ'
