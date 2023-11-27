export const send_vcache = async (type: string, data: Record<string, any>) => {
  const init = { method: 'POST', body: JSON.stringify(data) }
  try {
    await fetch(`/_sp/vcache/${type}`, init)
  } catch (ex) {
    console.log(ex)
  }
}
