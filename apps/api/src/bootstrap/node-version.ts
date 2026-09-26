export const MIN_NODE_MAJOR = 24;

/** Explains what to do when Node is too old; undefined when it is fine. */
export function nodeVersionProblem(version: string = process.versions.node): string | undefined {
  const major = Number(version.split(".")[0]);
  if (major >= MIN_NODE_MAJOR) return undefined;
  return `Node.js ${MIN_NODE_MAJOR} veya üstü gerekli; bu bilgisayarda ${version} var. https://nodejs.org adresinden LTS sürümünü kurun.`;
}

export function exitOnOldNode(): void {
  const problem = nodeVersionProblem();
  if (problem) {
    console.error(problem);
    process.exit(1);
  }
}
